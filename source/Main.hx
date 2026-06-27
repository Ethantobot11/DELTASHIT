package;

import CrashHandler;
import StorageUtil;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.util.FlxSave;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		var startFullscreen:Bool = false;
		var save = new FlxSave();
		#if MOBILE_CONTROLS_CONTROLS
		#if android
		StorageUtil.requestPermissions();
		#end
		Sys.setCwd(StorageUtil.getStorageDirectory());
		#end
		CrashHandler.init();

		save.bind("TurnBasedRPG");
		#if PC_CONTROLS_CONTROLS_CONTROLS
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
