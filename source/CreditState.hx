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