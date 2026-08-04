package;

#if wiiu
import leafy.core.LeafySprite;
import leafy.tweens.LeafyTween;
import leafy.tweens.LeafyEase;
#else
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
#end

class Coin extends #if wiiu LeafySprite #else FlxSprite #end
{
	public function new(x:Float, y:Float) 
	{
		super(x, y);
		
		#if haxe3ds
		loadGraphic("romfs:/assets/images/coin.png", false, 16, 16);
		#else
		loadGraphic(AssetPaths.coin__png, false, 16, 16);
		#end
	}

	override function kill()
	{
		alive = false;
		
		#if wiiu
		LeafyTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: LeafyEase.circOut, onComplete: finishKill});
		#else
		FlxTween.tween(this, {alpha: 0, y: y - 16}, 0.33, {ease: FlxEase.circOut, onComplete: finishKill});
		#end
	}

	function finishKill(_)
	{
		exists = false;
	}
}
