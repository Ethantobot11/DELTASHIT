package;

#if wiiu
import leafy.core.LeafyState;
import leafy.ui.LeafyButton;
import leafy.core.LeafyG;
import leafy.text.LeafyText;
#else
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.FlxG;
import flixel.text.FlxText;
#end
import MenuState;

class CreditState extends #if wiiu LeafyState #else FlxState #end
{
	#if wiiu
	var backButton:LeafyButton;
	#else
	var backButton:FlxButton;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("a very awesome guy : Ethantobot\n not really.... but who care ?", null);
		#end

		#if wiiu
		var text2 = new LeafyText(10, 10, 100, "Ethantobot");
		add(text2);
		backButton = new LeafyButton(0, 0, "back", backB);
		add(backButton);
		#else
		var text2 = new FlxText(10, 10, 100, "Ethantobot");
		add(text2);

		backButton = new FlxButton(0, 0, "back", backB);
		add(backButton);
		#end

		text2.screenCenter();
		super.create();
	}

	function backB()
	{
		#if wiiu
		LeafyG.switchState(new MenuState());
		#else
		FlxG.switchState(new MenuState());
		#end
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}
