package;

#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if haxe3ds
import haxe3ds.Console;
import citro.CitroG;
#end

using StringTools;

class CrashHandler {
    public static function init():Void {
        #if cpp
        untyped __global__.__hxcpp_set_critical_error_handler(onError);
        #elseif hl
        hl.Api.setErrorHandler(onError);
        #end
    }

    public static function protect(func:Void->Void, fallbackState:Dynamic):Void {
        try {
            func();
        } catch (e:Dynamic) {
            onError(e);
            try {
                if (fallbackState != null) {
                    CitroG.switchState(Type.createInstance(fallbackState, []));
                }
            } catch (e2:Dynamic) {
                #if haxe3ds
                Sys.println("Failed to recover to fallback state");
                #end
            }
        }
    }

    private static function onError(message:Dynamic):Void {
        final log:Array<String> = [];
        if (message != null) log.push(Std.string(message));
        log.push(haxe.CallStack.toString(haxe.CallStack.exceptionStack(true)));
        var fullLog = log.join('\n');

        #if sys
        saveErrorMessage(fullLog);
        #end

        #if haxe3ds
        Sys.println("\nCRITICAL ERROR:\n" + fullLog);
        #else
        trace("Critical Error: " + fullLog);
        #end
        
        #if (!haxe3ds)
        Sys.exit(1);
        #end
    }

    #if sys
    private static function saveErrorMessage(message:String):Void {
        try {
            #if haxe3ds
            var folder:String = "sdmc:/DELTASHIT/Logs/";
            #else
            var cwd:String = "";
            try { cwd = Sys.getCwd(); } catch(e:Dynamic) { cwd = ""; }
            final folder:String = cwd + 'logs/';
            #end

            if (!FileSystem.exists(folder)) FileSystem.createDirectory(folder);
            File.saveContent(folder + 'crash_' + Date.now().toString().replace(' ', '-').replace(':', "'") + '.txt', message);
        } catch (e:Dynamic) {
            trace('Couldn\'t save error message. (${e})');
        }
    }
    #end
}