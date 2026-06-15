package;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;

class MenuState extends FlxState
{
	var playButton:FlxButton;
	var creditButton:FlxButton;
	var titleText:FlxText;
	var optionsButton:FlxButton;
	#if (desktop || mobile)
	var exitButton:FlxButton;
	#end

	override public function create()
	{
		FlxG.sound.playMusic(AssetPaths.AUDIO_STORY__ogg, 1, true);
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

		creditButton = new FlxButton(-900, 0, "Credit", creditSwitch);
		creditButton.x = (FlxG.width / 2) + 300;
		creditButton.y = FlxG.height - creditButton.height - 10;
    	add(creditButton);

		#if (desktop || mobile)
		exitButton = new FlxButton(FlxG.width - 28, 8, "X", clickExit);
		exitButton.loadGraphic(AssetPaths.button__png, true, 20, 20);
		add(exitButton);
		#end

        playButton.screenCenter();
		//creditButton.screenCenter();
		text.screenCenter();
		text.x = 30;
		text.y = 60;
		super.create();
	}

	function clickPlay()
	{
	if (FlxG.sound.music != null)
    {
        FlxG.sound.music.stop();
    }
	//FlxG.switchState(PlayState.new);
    FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
	{
	FlxG.switchState(new PlayState());
	});
    }

	function creditSwitch()
    {
	//FlxG.switchState(CreditState.new);
	FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
    FlxG.switchState(new CreditState());
    }

	function clickOptions()
	{
	FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
	//FlxG.switchState(OptionsState.new);
	FlxG.switchState(new OptionsState());
	}

	#if (desktop || mobile)
	function clickExit()
	{
	Sys.exit(0);
	}
	#end

	

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
