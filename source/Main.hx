package;

#if wiiu
import leafy.LfEngine;
import leafy.states.LfState;
#else
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.FlxGame;
import openfl.display.Sprite;
#end
import CrashHandler;
import StorageUtil;

#if haxe3ds
import haxe3ds.Console;
import haxe3ds.services.APT;
import haxe3ds.services.GFX;
import haxe3ds.services.HID;
import haxe3ds.services.RomFS;
import haxe3ds.services.News;
#end

#if haxe3ds
@:headerInclude("3ds.h")
#end
class Main extends #if wiiu LfState #else Sprite #end
{
	public function new()
	{
		#if haxe3ds
		Console.init(TOP);
		RomFS.init();
		GFX.init();

		Sys.println("1. Services initialized.");

		var statusSuccess = true;

		try {
			if (!sys.FileSystem.exists("sdmc:/DELTASHIT/Logs")) {
				sys.FileSystem.createDirectory("sdmc:/DELTASHIT/Logs");
				Sys.println("2. Created directory: sdmc:/Chart-Editor/Logs");
			} else {
				Sys.println("2. Log directory already exists.");
			}
		} catch(e:Dynamic) {
			Sys.println("2. Warning/Error creating dir: " + e);
			statusSuccess = false;
		}

		if (statusSuccess) {
			Sys.println("3. Boot test successful!");
		} else {
			Sys.println("3. Boot completed with warnings.");
		}

		Sys.println("Press [START] to exit application.");

		while (APT.mainLoop()) {
			if (HID.keyPressed(HIDKey.START)) {
				break;
			}
		}

		GFX.exit();
		#end
		var startFullscreen:Bool = false;
		var save = new FlxSave();
		#if mobile
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		CrashHandler.init();

		save.bind("TurnBasedRPG");
		#if desktop
		if (save.data.fullscreen != null)
		{
			startFullscreen = save.data.fullscreen;
		}
		#end
		super();
		addChild(new FlxGame(320, 240, MenuState, 60, 60, false, startFullscreen));
		
		if (save.data.volume != null)
		{
			FlxG.sound.volume = save.data.volume;
		}

		#if DISCORD_ALLOWED
		DiscordClient.prepare();
		#end
		save.close();
	}
}
