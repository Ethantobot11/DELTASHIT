package;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.FlxG;
import MenuState;

class CreditState extends FlxState
{
    var backButton:FlxButton;

	override public function create()
	{

		#if DISCORD_ALLOWED
		DiscordClient.changePresence("a very awesome guy : Ethantobot\n not really.... but who care ?", null);
		#end

		var text2 = new flixel.text.FlxText(10, 10, 100, "Ethantobot");
		add(text2);

        backButton = new FlxButton(0, 0, "back", backB);
    	add(backButton);

        text2.screenCenter();
		super.create();
	}

    function backB()
    {
	//FlxG.switchState(CreditState.new);
    FlxG.switchState(new MenuState());
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}