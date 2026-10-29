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
        titleText.screenCenter(X);
        add(titleText);

        volumeText = new CitroText(0, titleText.y + 30, "Volume");
        volumeText.alignment = CENTER;
        volumeText.screenCenter(X);
        add(volumeText);

        volumeDownButton = new CitroButton(0, volumeText.y + 30, 40, 30, "-", clickVolumeDown);
        volumeDownButton.screenCenter(X);
        volumeDownButton.x -= 100;
        volumeDownButton.bottom = true;
        add(volumeDownButton);

        volumeUpButton = new CitroButton(0, volumeText.y + 30, 40, 30, "+", clickVolumeUp);
        volumeUpButton.screenCenter(X);
        volumeUpButton.x += 100;
        volumeUpButton.bottom = true;
        add(volumeUpButton);

        volumeBar = new CitroBar(volumeDownButton.x + 50, volumeDownButton.y, 320 - 140, 30);
        volumeBar.bottom = true;
        add(volumeBar);

        volumeAmountText = new CitroText(0, 0, "100%");
        volumeAmountText.alignment = CENTER;
        volumeAmountText.screenCenter(X);
        volumeAmountText.bottom = true;
        volumeAmountText.y = volumeBar.y + 5;
        add(volumeAmountText);

        clearDataButton = new CitroButton(0, 200, 120, 30, "Clear Data", clickClearData);
        clearDataButton.bottom = true;
        clearDataButton.screenCenter(X);
        clearDataButton.x -= 70;
        add(clearDataButton);

        backButton = new CitroButton(0, 200, 120, 30, "Back", clickBack);
        backButton.bottom = true;
        backButton.screenCenter(X);
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
        updateVolume();
    }

    function clickVolumeUp() {
        updateVolume();
    }

    function updateVolume() {
        var volume:Int = 100;
        volumeBar.value = volume;
        volumeAmountText.text = volume + "%";
    }
}