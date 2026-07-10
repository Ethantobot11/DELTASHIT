package;

#if wiiu
import leafy.LfEngine;
import leafy.states.LeafyState;
#else
import flixel.FlxG;
import flixel.util.FlxSave;
import flixel.FlxGame;
import openfl.display.Sprite;
#end
import CrashHandler;
import StorageUtil;

class Main extends #if wiiu LfState #else Sprite #end
{
	public function new()
	{
		#if wiiu
		super();
		CrashHandler.init();
		LeafyG.initGame(320, 240, new MenuState()); 
		#else
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
		#end
	}
}
