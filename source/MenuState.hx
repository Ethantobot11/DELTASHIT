package;

import citro.CitroG;
import citro.backend.CitroG.sound.load;
import citro.object.CitroButton;
import citro.object.CitroText;
import citro.state.CitroState;

class MenuState extends CitroState
{
	public static var shittaleversion:String = 'DELTARUNE';
    
	var playButton:CitroButton;
	var creditButton:CitroButton;
	var titleText:CitroText;
	var optionsButton:CitroButton;
	var music:CitroG.sound.load;

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("WHOA SINCE WHEN THERE A MENU AND DISCORD RPC HERE ?", null);
		#end

		music = new CitroG.sound.load(AssetPaths.AUDIO_STORY__ogg);
		music.looped = true;
		music.play();

		var text = new CitroText(30, 60, "DELTARUNE : CHAPTER 7");
		add(text);

		titleText = new CitroText(20, 0, "HaxeFlixel\nTutorial\nGame");
		titleText.alignment = CENTER;
		titleText.screenCenter();
		add(titleText);

		playButton = new CitroButton(0, 0, 100, 30, "Play", clickPlay);
		playButton.screenCenter();
		playButton.y = CitroG.HEIGHT - playButton.height - 10;
		add(playButton);

		optionsButton = new CitroButton(0, 0, 100, 30, "Options", clickOptions);
		optionsButton.screenCenter();
		optionsButton.x += 120;
		optionsButton.y = CitroG.HEIGHT - optionsButton.height - 10;
		add(optionsButton);

		creditButton = new CitroButton(0, 0, 100, 30, "Credit", creditSwitch);
		creditButton.screenCenter();
		creditButton.x -= 120;
		creditButton.y = CitroG.HEIGHT - creditButton.height - 10;
		add(creditButton);

		super.create();
	}

	function clickPlay()
	{
		music.stop();
		CitroG.switchState(new PlayState());
	}

	function creditSwitch()
	{
		CitroG.switchState(new CreditState());
	}

	function clickOptions()
	{
		CitroG.switchState(new OptionsState());
	}
}