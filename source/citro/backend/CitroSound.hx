package citro.backend;

#if (!wiiu || !cafe)
import citro.CitroG;
import citro.VoidPtr;
import cpp.RawPointer;

@:native("CWAV")
extern class CWAVData {}

@:headerCode('
#include "3ds.h"
#include "cwav.h"
')
class CWAVHelper {
    public static inline function useEnvironment(envMode:Int):Void {
        untyped __cpp__("cwavUseEnvironment({0})", envMode);
    }

    public static inline function fileLoad(out:RawPointer<CWAVData>, filename:String, maxSPlays:Int):Void {
        untyped __cpp__("cwavFileLoad({0}, {1}, {2})", out, filename, maxSPlays);
    }

    public static inline function play(cwav:RawPointer<CWAVData>, leftChannel:Int, rightChannel:Int):Void {
        untyped __cpp__("cwavPlay({0}, {1}, {2})", cwav, leftChannel, rightChannel);
    }

    public static inline function stop(cwav:RawPointer<CWAVData>, leftChannel:Int, rightChannel:Int):Void {
        untyped __cpp__("cwavStop({0}, {1}, {2})", cwav, leftChannel, rightChannel);
    }

    public static inline function fileFree(cwav:RawPointer<CWAVData>):Void {
        untyped __cpp__("cwavFileFree({0})", cwav);
    }
}

class CitroSound {
    public var volume:Float = 1.0;
    public var looped:Bool = false;
    public var isPlaying(default, null):Bool = false;
    public var path:String;
    
    private var cwavPtr:RawPointer<CWAVData>;
    private static var initialized:Bool = false;

    public function new(path:String) {
        this.path = path;
        this.cwavPtr = null;
    }

    private function init():Void {
        if (initialized) return;
        untyped __cpp__("ndspInit()");
        CWAVHelper.useEnvironment(0);
        initialized = true;
        trace("CitroG.sound.load initialized with NDSP.");
    }

    public function load():Void {
        init();
        if (cwavPtr != null) return;
        
        var cached = CitroG.caches.get(path);
        if (cached != null) {
            this.cwavPtr = cast cached;
            return;
        }

        this.cwavPtr = untyped __cpp__("calloc(1, sizeof(CWAV))");
        CWAVHelper.fileLoad(this.cwavPtr, path, 4);

        var status:Int = untyped __cpp__("((CWAV*){0})->loadStatus", this.cwavPtr);
        if (status == 1) {
            CitroG.caches.set(path, cast this.cwavPtr);
            trace('Successfully cached and loaded sound: $path');
        } else {
            trace('ERROR: Failed to load CWAV file "$path". Status code: $status');
            untyped __cpp__("free({0})", this.cwavPtr);
            this.cwavPtr = null;
        }
    }

    public function play(?force:Bool = false):Void {
        if (cwavPtr == null) {
            load();
        }
        if (cwavPtr != null) {
            untyped __cpp__("((CWAV*){0})->volume = {1}", this.cwavPtr, this.volume);
            CWAVHelper.play(this.cwavPtr, 0, -1); 
            this.isPlaying = true;
        }
    }

    public function stop():Void {
        if (cwavPtr != null) {
            CWAVHelper.stop(this.cwavPtr, -1, -1); 
            this.isPlaying = false;
        }
    }
    
    public function pause():Void {
        stop();
    }
    
    public function resume():Void {
        play();
    }
}
#end