package;

#if wiiu
import leafy.core.LeafyState;
import leafy.core.LeafyG;
import leafy.text.LeafyText;
#else
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
#end

class MenuState extends #if wiiu LeafyState #else FlxState #end
{
	public static var shittaleversion:String = 'DELTARUNE';
	
	#if !wiiu
	var playButton:FlxButton;
	var creditButton:FlxButton;
	var titleText:FlxText;
	var optionsButton:FlxButton;
	#if (desktop || mobile)
	var exitButton:FlxButton;
	#end
	#else
	var titleText:LeafyText;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("WHOA SINCE WHEN THERE A MENU AND DISCORD RPC HERE ?", null);
		#end

		#if wiiu
		var text = new LeafyText(10, 10, 100, "DELTARUNE : CHAPTER 7");
		add(text);

		titleText = new LeafyText(20, 0, 0, "HaxeFlixel\nTutorial\nGame", 22);
		add(titleText);
		#else
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(AssetPaths.AUDIO_STORY__ogg, 1, true);
		}
		var text = new flixel.text.FlxText(10, 10, 100, "DELTARUNE : CHAPTER 7");
		add(text);

		titleText = new FlxText(20, 0, 0, "HaxeFlixel\nTutorial\nGame", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(X);
		add(titleText);

		playButton = new FlxButton(0, 0, "Play", clickPlay);
		playButton.x = (FlxG.width / 2) - playButton.width - 10;
		playButton.y = FlxG.height - playButton.height - 10;
		add(playButton);

		optionsButton = new FlxButton(600, 0, "Options", clickOptions);
		optionsButton.x = (FlxG.width / 2) + 10;
		optionsButton.y = FlxG.height - optionsButton.height - 10;
		add(optionsButton);

		creditButton = new FlxButton(300, 0, "Credit", creditSwitch);
		creditButton.x = (FlxG.width / 2) + -100;
		creditButton.y = FlxG.height - creditButton.height - 10;
		add(creditButton);

		#if (desktop || mobile)
		exitButton = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		exitButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		add(exitButton);
		#end

		playButton.screenCenter();
		text.screenCenter();
		text.x = 30;
		text.y = 60;
		#end

		super.create();
	}

	function clickPlay()
	{
		#if wiiu
		LeafyG.switchState(new PlayState());
		#else
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
		}
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(new PlayState());
		});
		#end
	}

	function creditSwitch()
	{
		#if wiiu
		LeafyG.switchState(new CreditState());
		#else
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
		FlxG.switchState(new CreditState());
		#end
	}

	function clickOptions()
	{
		#if wiiu
		LeafyG.switchState(new OptionsState());
		#else
		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
		FlxG.switchState(new OptionsState());
		#end
	}

	#if (desktop || mobile)
	function clickExit()
	{
		#if DISCORD_ALLOWED
		DiscordClient.shutdown();
		trace("turned off rpc ?");
		#end
		Sys.exit(0);
	}
	#end

	override public function update(elapsed:Float)
	{
		#if wiiu
		(WiiUGamepad.justPressed(A)) clickPlay();
		#end
		super.update(elapsed);
	}
}
