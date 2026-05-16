package;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import Coin;
import Enemy;
using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	public static var tiles__png:String = "assets/images/tiles.png";
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var hud:HUD;
	var money:Int = -10;
	var health:Int = 20;
	var inCombat:Bool = false;
	var combatHud:CombatHUD;
	var ending:Bool;
	var won:Bool;
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);
		
		coins = new FlxTypedGroup<Coin>();
		add(coins);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);
		FlxG.camera.follow(player, TOPDOWN, 1);
		hud = new HUD();
		add(hud);	
		combatHud = new CombatHUD();
		add(combatHud);
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end
		super.create();
	}

	function placeEntities(entity:EntityData)
	{
	var x = entity.x;
	var y = entity.y;

	switch (entity.name)
	{
	case "player":
		player.setPosition(x, y);

	case "coin":
		coins.add(new Coin(x + 4, y + 4));

	case "enemy":
		enemies.add(new Enemy(x + 4, y, REGULAR));

	case "boss":
		enemies.add(new Enemy(x + 4, y, BOSS));
	}
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
	if (player.alive && player.exists && coin.alive && coin.exists)
	{
		money++;
		hud.updateHUD(health, money);
		coin.kill();
	}
	}

	function checkEnemyVision(enemy:Enemy)
	{
	if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
	{
		enemy.seesPlayer = true;
		enemy.playerPosition = player.getMidpoint();
	}
	else
	{
		enemy.seesPlayer = false;
	}
	}
	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
	if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
	{
		startCombat(enemy);
	}
	}

	function startCombat(enemy:Enemy)
	{
	inCombat = true;
	player.active = false;
	enemies.active = false;
	#if mobile
	virtualPad.visible = false;
	#end
	combatHud.initCombat(health, enemy);
	}

	function doneFadeOut()
	{
	FlxG.switchState(new GameOverState(won, money));
	}

	override public function update(elapsed:Float)
	{
		if (inCombat)
	{
	if (!combatHud.visible)
	{
	health = combatHud.playerHealth;
	hud.updateHUD(health, money);
	if (combatHud.outcome == DEFEAT)
	{
		ending = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
	}
	else
	{
		if (combatHud.outcome == VICTORY)
		{
			combatHud.enemy.kill();
			if (combatHud.enemy.type == BOSS)
			{
				won = true;
				ending = true;
				FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
			}
		}
		else
		{
			combatHud.enemy.flicker();
		}
		inCombat = false;
		player.active = true;
		enemies.active = true;
	}
	}
	}
	else
	{
	FlxG.collide(player, walls);
	FlxG.overlap(player, coins, playerTouchCoin);
	FlxG.collide(enemies, walls);
	enemies.forEachAlive(checkEnemyVision);
	FlxG.overlap(player, enemies, playerTouchEnemy);
	}
		super.update(elapsed);
	if (ending)
	{
	return;
	}
	}
}
