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

        var text2 = new CitroText(10, 10, "Ethantobot");
        add(text2);
        
        backButton = new CitroButton(0, 0, 100, 30, "back", backB);
        backButton.bottom = true;
        add(backButton);

        text2.screenCenter();
        super.create();
    }

    function backB() {
        CitroG.switchState(new MenuState());
    }
}