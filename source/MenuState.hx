package;

import citro.CitroG;
import citro.backend.CitroSound;
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
    var music:CitroSound;

    override public function create()
    {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("WHOA SINCE WHEN THERE A MENU AND DISCORD RPC HERE ?", null);
        #end

        music = CitroG.sound.load(AssetPaths.AUDIO_STORY__cwav);
        music.looped = true;
        music.play();

        var titleText1 = new CitroText(0, 30, "DELTARUNE : CHAPTER 7");
        titleText1.alignment = CENTER;
        titleText1.screenCenter(X);
        titleText1.bottom = false;
        add(titleText1);

        titleText = new CitroText(0, 80, "HaxeFlixel\nTutorial\nGame");
        titleText.alignment = CENTER;
        titleText.screenCenter(X);
        titleText.bottom = false;
        add(titleText);

        playButton = new CitroButton(0, 180, 100, 30, "Play", clickPlay);
        playButton.bottom = true;
        playButton.screenCenter(X);
        playButton.x -= 110;
        add(playButton);

        optionsButton = new CitroButton(0, 180, 100, 30, "Options", clickOptions);
        optionsButton.bottom = true;
        optionsButton.screenCenter(X);
        add(optionsButton);

        creditButton = new CitroButton(0, 180, 100, 30, "Credit", creditSwitch);
        creditButton.bottom = true;
        creditButton.screenCenter(X);
        creditButton.x += 110;
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