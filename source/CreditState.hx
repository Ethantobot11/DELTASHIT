package;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.object.CitroButton;
import citro.CitroG;

class CreditState extends CitroState {
    var backButton:CitroButton;

    override public function create() {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("a very awesome guy : Ethantobot", null);
        #end

        var text2 = new CitroText(-600, 60, "Ethantobot");
        text2.alignment = CENTER;
        text2.screenCenter(X);
        add(text2);
        
        backButton = new CitroButton(0, 200, 100, 30, "back", backB);
        backButton.bottom = true;
        backButton.screenCenter(X);
        add(backButton);

        super.create();
    }

    function backB() {
        CitroG.switchState(new MenuState());
    }
}