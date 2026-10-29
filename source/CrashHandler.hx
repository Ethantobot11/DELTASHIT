package;

import openfl.events.UncaughtErrorEvent;
import openfl.events.ErrorEvent;
import openfl.errors.Error;
import flixel.FlxG;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
#if haxe3ds
import haxe3ds.Console;
#end

using StringTools;

class CrashHandler {
    public static function init():Void {
        if (openfl.Lib.current != null && openfl.Lib.current.loaderInfo != null) {
            openfl.Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onUncaughtError);
        }
        #if cpp
        untyped __global__.__hxcpp_set_critical_error_handler(onError);
        #elseif hl
        hl.Api.setErrorHandler(onError);
        #end
    }

    private static function onUncaughtError(e:UncaughtErrorEvent):Void {
        e.preventDefault();
        e.stopPropagation();
        e.stopImmediatePropagation();

        var m:String = Std.string(e.error);
        if (Std.isOfType(e.error, Error)) m = cast(e.error, Error).message;
        else if (Std.isOfType(e.error, ErrorEvent)) m = cast(e.error, ErrorEvent).text;
        
        var stack = haxe.CallStack.exceptionStack();
        var stackLabelArr:Array<String> = [];
        for (item in stack) {
            switch (item) {
                case CFunction: stackLabelArr.push("Non-Haxe (C) Function");
                case Module(c): stackLabelArr.push('Module ${c}');
                case FilePos(parent, file, line, col):
                    switch (parent) {
                        case Method(cla, func): stackLabelArr.push('${file.replace(".hx", "")}.$func() [line $line]');
                        case _: stackLabelArr.push('${file.replace(".hx", "")} [line $line]');
                    }
                case LocalFunction(v): stackLabelArr.push('Local Function ${v}');
                case Method(cl, m): stackLabelArr.push('${cl} - ${m}');
            }
        }
        var fullErrorLog = '$m\n${stackLabelArr.join("\r\n")}';

        #if sys
        saveErrorMessage(fullErrorLog);
        #end

        #if haxe3ds
        Sys.println("\nCRASH OCCURRED:\n" + fullErrorLog);
        #else
        if (FlxG.stage != null && FlxG.stage.window != null) {
            FlxG.stage.window.alert(fullErrorLog, "Error!");
        }
        #end
        
        #if (!haxe3ds)
        lime.system.System.exit(1);
        #end
    }

    #if (cpp || hl)
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
        if (FlxG.stage != null && FlxG.stage.window != null) {
            FlxG.stage.window.alert(fullLog, "Critical Error!");
        }
        #end
        
        #if (!haxe3ds)
        lime.system.System.exit(1);
        #end
    }
    #end

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