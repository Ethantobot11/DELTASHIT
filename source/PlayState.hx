package;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.FlxState;
import flixel.sound.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import Coin;
import Enemy;
using flixel.util.FlxSpriteUtil;
import flixel.ui.FlxVirtualPad;
import PsychOgmoLoader;

class PlayState extends FlxState
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
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("WE CALL IT : PLAYSTATE CUZ FUCK YOU", null);
		#end
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		music = FlxG.sound.load(AssetPaths.boxing_game__ogg, 1, true);
		#if !ios
		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		#elseif ios
		map = new PsychOgmoLoader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
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
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end
		coins = new FlxTypedGroup<Coin>();
		add(coins);
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
	#if mobile
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
				//won = true;
				//ending = true;
				FlxG.switchState(new PlayState2());
				FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
			}
			#if DISCORD_ALLOWED
			DiscordClient.changePresence("WE CALL IT : PLAYSTATE CUZ FUCK YOU", null);
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
		#if mobile
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
