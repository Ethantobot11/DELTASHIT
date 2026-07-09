package;

#if wiiu
import leafy.group.LeafyGroup.LeafyTypedGroup;
import leafy.core.LeafySprite;
import leafy.core.LeafyG;
import leafy.text.LeafyText;
#else
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;
#end

class HUD extends #if wiiu LeafyTypedGroup<LeafySprite> #else FlxTypedGroup<FlxSprite> #end
{
	#if wiiu
	var background:LeafySprite;
	var healthCounter:LeafyText;
	var moneyCounter:LeafyText;
	var healthIcon:LeafySprite;
	var moneyIcon:LeafySprite;
	#else
	var background:FlxSprite;
	var healthCounter:FlxText;
	var moneyCounter:FlxText;
	var healthIcon:FlxSprite;
	var moneyIcon:FlxSprite;
	#end

	public function new()
	{
		super();
		
		#if wiiu
		background = new LeafySprite(0, 0, "assets/images/hud_bg.png");
		healthCounter = new LeafyText(16, 2, 0, "20 / 20", 8);
		moneyCounter = new LeafyText(100, 2, 0, "0", 8);
		
		healthIcon = new LeafySprite(4, 4, "assets/images/health.png");
		moneyIcon = new LeafySprite(200, 4, "assets/images/coin.png");
		
		add(background);
		add(healthIcon);
		add(moneyIcon);
		add(healthCounter);
		add(moneyCounter);
		#else
		background = new FlxSprite().makeGraphic(FlxG.width, 20, FlxColor.BLACK);
		background.drawRect(0, 19, FlxG.width, 1, FlxColor.WHITE);
		healthCounter = new FlxText(16, 2, 0, "20 / 20", 8);
		healthCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		moneyCounter = new FlxText(0, 2, 0, "0", 8);
		moneyCounter.setBorderStyle(SHADOW, FlxColor.GRAY, 1, 1);
		healthIcon = new FlxSprite(4, healthCounter.y + (healthCounter.height/2)  - 4, AssetPaths.health__png);
		moneyIcon = new FlxSprite(FlxG.width - 12, moneyCounter.y + (moneyCounter.height/2)  - 4, AssetPaths.coin__png);
		moneyCounter.alignment = RIGHT;
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		
		add(background);
		add(healthIcon);
		add(moneyIcon);
		add(healthCounter);
		add(moneyCounter);
		
		forEach(function(sprite) sprite.scrollFactor.set(0, 0));
		#end
	}

	public function updateHUD(health:Int, money:Int)
	{
		healthCounter.text = health + " / 20";
		moneyCounter.text = Std.string(money);
		#if !wiiu
		moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
		#end
	}
}
