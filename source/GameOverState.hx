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
        titleText.screenCenter();
        add(titleText);

        messageText = new CitroText(0, (CitroG.HEIGHT / 2) - 18, "Final Score:");
        messageText.alignment = CENTER;
        messageText.screenCenter();
        add(messageText);

        scoreIcon = new CitroSprite((CitroG.WIDTH / 2) - 8, 0);
        scoreIcon.loadGraphic("romfs:/assets/images/coin.t3x");
        scoreIcon.screenCenter();
        add(scoreIcon);

        scoreText = new CitroText((CitroG.WIDTH / 2), 0, Std.string(score));
        scoreText.screenCenter();
        add(scoreText);

        var highscore = checkHighscore(score);
        highscoreText = new CitroText(0, (CitroG.HEIGHT / 2) + 10, "Highscore: " + highscore);
        highscoreText.alignment = CENTER;
        highscoreText.screenCenter();
        add(highscoreText);

        mainMenuButton = new CitroButton(0, CitroG.HEIGHT - 32, 100, 30, "Main Menu", switchToMainMenu);
        mainMenuButton.screenCenter();
        mainMenuButton.bottom = true;
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