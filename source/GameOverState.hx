package;

#if wiiu
import leafy.core.LeafyState;
import leafy.core.LeafyG;
import leafy.core.LeafySprite;
import leafy.text.LeafyText;
#else
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
#end

class GameOverState extends #if wiiu LeafyState #else FlxState #end
{
	#if wiiu
	var titleText:LeafyText;
	var messageText:LeafyText;
	var scoreIcon:LeafySprite;
	var scoreText:LeafyText;
	var highscoreText:LeafyText;
	#else
	var titleText:FlxText;
	var messageText:FlxText;
	var scoreIcon:FlxSprite;
	var scoreText:FlxText;
	var highscoreText:FlxText;
	var mainMenuButton:FlxButton;
	#end

	public function new(win:Bool, score:Int)
	{
		super();

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("XD BRO LOST : GameOverState ;-;", null);
		#end

		#if (FLX_MOUSE && !wiiu)
		FlxG.mouse.visible = true;
		#end

		#if wiiu
		titleText = new LeafyText(0, 20, 0, if (win) "You Win!" else "Game Over!", 22);
		add(titleText);

		messageText = new LeafyText(0, 100, 0, "Final Score:", 8);
		add(messageText);

		scoreIcon = new LeafySprite(100, 100, "assets/images/coin.png");
		add(scoreIcon);

		scoreText = new LeafyText(120, 100, 0, Std.string(score), 8);
		add(scoreText);

		var highscore = checkHighscore(score);
		highscoreText = new LeafyText(0, 140, 0, "Highscore: " + highscore, 8);
		add(highscoreText);
		#else
		if (FlxG.sound.music == null)
		{
			FlxG.sound.playMusic(AssetPaths.LOSE__ogg, 1, true);
		}

		titleText = new FlxText(0, 20, 0, if (win) "You Win!" else "Game Over!", 22);
		titleText.alignment = CENTER;
		titleText.screenCenter(FlxAxes.X);
		add(titleText);

		messageText = new FlxText(0, (FlxG.height / 2) - 18, 0, "Final Score:", 8);
		messageText.alignment = CENTER;
		messageText.screenCenter(FlxAxes.X);
		add(messageText);

		scoreIcon = new FlxSprite((FlxG.width / 2) - 8, 0, AssetPaths.coin__png);
		scoreIcon.screenCenter(FlxAxes.Y);
		add(scoreIcon);

		scoreText = new FlxText((FlxG.width / 2), 0, 0, Std.string(score), 8);
		scoreText.screenCenter(FlxAxes.Y);
		add(scoreText);

		var highscore = checkHighscore(score);

		highscoreText = new FlxText(0, (FlxG.height / 2) + 10, 0, "Highscore: " + highscore, 8);
		highscoreText.alignment = CENTER;
		highscoreText.screenCenter(FlxAxes.Y);
		add(highscoreText);

		mainMenuButton = new FlxButton(0, FlxG.height - 32, "Main Menu", switchToMainMenu);
		mainMenuButton.screenCenter(FlxAxes.X);
		mainMenuButton.onUp.sound = FlxG.sound.load(AssetPaths.select__wav);
		add(mainMenuButton);

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);
		#end
	}

	function checkHighscore(score:Int):Int
	{
		var highscore:Int = score;
		#if wiiu
		return highscore;
		#else
		if (FlxG.save.data.highscore != null && FlxG.save.data.highscore > highscore)
		{
			highscore = FlxG.save.data.highscore;
		}
		else
		{
			FlxG.save.data.highscore = highscore;
		}
		return highscore;
		#end
	}

	function switchToMainMenu():Void
	{
		#if wiiu
		LeafyG.switchState(new MenuState());
		#else
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, function()
		{
			FlxG.switchState(MenuState.new);
		});
		#end
	}
}
