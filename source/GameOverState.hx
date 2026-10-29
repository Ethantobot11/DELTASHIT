package;

import citro.state.CitroState;
import citro.object.CitroText;
import citro.object.CitroSprite;
import citro.object.CitroButton;
import citro.CitroG;

class GameOverState extends CitroState {
    var titleText:CitroText;
    var messageText:CitroText;
    var scoreIcon:CitroSprite;
    var scoreText:CitroText;
    var highscoreText:CitroText;
    var mainMenuButton:CitroButton;

    public function new(win:Bool, score:Int) {
        super();
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("XD BRO LOST : GameOverState ;-;", null);
        #end

        titleText = new CitroText(0, 20, if (win) "You Win!" else "Game Over!");
        titleText.alignment = CENTER;
        titleText.screenCenter(X);
        add(titleText);

        messageText = new CitroText(0, 100, "Final Score:");
        messageText.alignment = CENTER;
        messageText.screenCenter(X);
        add(messageText);

        scoreIcon = new CitroSprite(0, 0);
        scoreIcon.loadGraphic("romfs:/assets/images/coin.t3x");
        scoreIcon.x = (320 / 2) - 12;
        scoreIcon.y = 130;
        scoreIcon.bottom = true;
        add(scoreIcon);

        scoreText = new CitroText(0, 0, Std.string(score));
        scoreText.x = (320 / 2) + 12;
        scoreText.y = 132;
        scoreText.bottom = true;
        add(scoreText);

        var highscore = checkHighscore(score);
        highscoreText = new CitroText(0, 160, "Highscore: " + highscore);
        highscoreText.alignment = CENTER;
        highscoreText.bottom = true;
        highscoreText.screenCenter(X);
        add(highscoreText);

        mainMenuButton = new CitroButton(0, 200, 100, 30, "Main Menu", switchToMainMenu);
        mainMenuButton.bottom = true;
        mainMenuButton.screenCenter(X);
        add(mainMenuButton);
    }

    function checkHighscore(score:Int):Int {
        var highscore:Int = score;
        if (CitroG.save.data.highscore != null && CitroG.save.data.highscore > highscore) {
            highscore = CitroG.save.data.highscore;
        } else {
            CitroG.save.data.highscore = highscore;
            CitroG.save.flush();
        }
        return highscore;
    }

    function switchToMainMenu():Void {
        CitroG.switchState(new MenuState());
    }
}