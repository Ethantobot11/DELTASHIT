package;
import Coin;
import Enemy;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState2 extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 20;
	var inCombat:Bool = false;
	var combatHud:CombatHUD;
	var ending:Bool;
	var won:Bool;
	var music:FlxSound;
	public static var instance:PlayState2;
	#if MOBILE_CONTROLS
	public var manager:MobileControls;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("BRO I HAD NO BETTER NAME THAN PLAYSTATE 2.... OK ????!!!!!", null);
		#end
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		music = FlxG.sound.load(AssetPaths.boxing_game__ogg, 1, true);
		#if !ios
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_002__json);
		#elseif ios
		map = new PsychOgmoLoader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_002__json);
		#end
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, ANY);
		add(walls);

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
		coins = new FlxTypedGroup<Coin>();
		add(coins);
		#if MOBILE_CONTROLS
		manager = new MobileControls();
		add(manager);

		manager.addJoyStick('TEST');
		#end

		music.play();
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
		music.pause();
		startCombat(enemy);
	}
	}

	function startCombat(enemy:Enemy)
	{
	#if DISCORD_ALLOWED
	DiscordClient.changePresence("FIGHTING", null);
	#end
	inCombat = true;
	player.active = false;
	enemies.active = false;
		#if MOBILE_CONTROLS_CONTROLS
	virtualPad.visible = false;
	#end
	combatHud.initCombat(health, enemy);
	}

	function doneFadeOut()
	{
	FlxG.sound.music.pause();
	FlxG.switchState(new GameOverState(won, money));
	}

	override public function update(elapsed:Float)
	{
		if (inCombat)
	{
	if (!combatHud.visible)
	{
	music.resume();
	health = combatHud.playerHealth;
	hud.updateHUD(health, money);
	if (combatHud.outcome == DEFEAT)
	{
		ending = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
		music.pause();
	}
	else
	{
		if (combatHud.outcome == VICTORY)
		{
			music.resume();
			combatHud.enemy.kill();
			if (combatHud.enemy.type == BOSS)
			{
				won = true;
				ending = true;
				FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
			}
			#if DISCORD_ALLOWED
			DiscordClient.changePresence("BRO I HAD NO BETTER NAME THAN PLAYSTATE 2.... OK ????!!!!!", null);
			#end
			music.resume();	
		}
		else
		{
			combatHud.enemy.flicker();
		}
		inCombat = false;
		player.active = true;
		enemies.active = true;
					#if MOBILE_CONTROLS_CONTROLS
	    virtualPad.visible = true;
    	#end
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
	music.pause();
	return;
	}
	}
}
