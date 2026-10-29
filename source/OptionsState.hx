package;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.object.CitroButton;
import citro.object.CitroBar;
import citro.CitroG;

class OptionsState extends CitroState {
    var titleText:CitroText;
    var volumeBar:CitroBar;
    var volumeText:CitroText;
    var volumeAmountText:CitroText;
    var volumeDownButton:CitroButton;
    var volumeUpButton:CitroButton;
    var clearDataButton:CitroButton;
    var backButton:CitroButton;

    public static var discordRPC:Bool = true;

    override public function create():Void {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("CURRENTLY CHANGING THE OPTIONS", null);
        #end

        titleText = new CitroText(0, 20, "Options");
        titleText.alignment = CENTER;
        titleText.screenCenter();
        add(titleText);

        volumeText = new CitroText(0, titleText.y + 30, "Volume");
        volumeText.alignment = CENTER;
        volumeText.screenCenter();
        add(volumeText);

        volumeDownButton = new CitroButton(0, volumeText.y + 30, 40, 30, "-", clickVolumeDown);
        volumeDownButton.screenCenter();
        volumeDownButton.x -= 100;
        add(volumeDownButton);

        volumeUpButton = new CitroButton(0, volumeText.y + 30, 40, 30, "+", clickVolumeUp);
        volumeUpButton.screenCenter();
        volumeUpButton.x += 100;
        add(volumeUpButton);

        volumeBar = new CitroBar(volumeDownButton.x + 50, volumeDownButton.y, CitroG.WIDTH - 140, 30);
        add(volumeBar);

        volumeAmountText = new CitroText(0, 0, "100%");
        volumeAmountText.alignment = CENTER;
        volumeAmountText.screenCenter();
        volumeAmountText.y = volumeBar.y + 5;
        add(volumeAmountText);

        clearDataButton = new CitroButton(0, CitroG.HEIGHT - 60, 120, 30, "Clear Data", clickClearData);
        clearDataButton.screenCenter();
        clearDataButton.x -= 70;
        add(clearDataButton);

        backButton = new CitroButton(0, CitroG.HEIGHT - 60, 120, 30, "Back", clickBack);
        backButton.screenCenter();
        backButton.x += 70;
        add(backButton);

        updateVolume();
        super.create();
    }

    function clickClearData() {
        CitroG.save.data = {};
        updateVolume();
    }

    function clickBack() {
        CitroG.save.flush();
        CitroG.switchState(new MenuState());
    }

    function clickVolumeDown() {
        //flixel.FlxG.sound.volume -= 0.1;
        updateVolume();
    }

    function clickVolumeUp() {
        //flixel.FlxG.sound.volume += 0.1;
        updateVolume();
    }

    function updateVolume() {
        var volume:Int = 100;
        volumeBar.value = volume;
        volumeAmountText.text = volume + "%";
    }
}