package;

#if wiiu
import leafy.core.LeafyState;
import leafy.core.LeafyG;
import leafy.core.LeafySprite;
import leafy.group.LeafyGroup.LeafyTypedGroup;
#else
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxVirtualPad;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import PsychOgmoLoader;
#end

import Coin;
import Enemy;

class PlayState extends #if wiiu LeafyState #else FlxState #end
{
	var player:Player;
	var hud:HUD;
	var money:Int = 0;
	var health:Int = 20;
	var inCombat:Bool = false;
	var combatHud:CombatHUD;
	var ending:Bool;
	var won:Bool;

	#if !wiiu
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;
	var music:FlxSound;
	#else
	var coins:LeafyTypedGroup<Coin>;
	var enemies:LeafyTypedGroup<Enemy>;
	#end

	#if (mobile && !wiiu)
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create()
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("WE CALL IT : PLAYSTATE CUZ FUCK YOU", null);
		#end

		#if (FLX_MOUSE && !wiiu)
		FlxG.mouse.visible = false;
		#end

		#if wiiu
		enemies = new LeafyTypedGroup<Enemy>();
		add(enemies);

		coins = new LeafyTypedGroup<Coin>();
		add(coins);

		player = new Player();
		player.setPosition(100, 100);
		add(player);

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);
		#else
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
		#end

		super.create();
	}

	#if !wiiu
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
	#end

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
		#if wiiu
		var dx = player.x - enemy.x;
		var dy = player.y - enemy.y;
		var dist = Math.sqrt(dx * dx + dy * dy);
		if (dist < 150) {
			enemy.seesPlayer = true;
			enemy.playerPosition.x = player.x;
			enemy.playerPosition.y = player.y;
		} else {
			enemy.seesPlayer = false;
		}
		#else
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
		#end
	}

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		#if wiiu
		if (player.alive && player.exists && enemy.alive && enemy.exists)
		{
			startCombat(enemy);
		}
		#else
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			music.pause();
			startCombat(enemy);
		}
		#end
	}

	function startCombat(enemy:Enemy)
	{
		#if DISCORD_ALLOWED
		DiscordClient.changePresence("FIGHTING", null);
		#end
		inCombat = true;
		player.active = false;
		enemies.active = false;
		#if (mobile && !wiiu)
		virtualPad.visible = false;
		#end
		combatHud.initCombat(health, enemy);
	}

	function doneFadeOut()
	{
		#if !wiiu
		FlxG.sound.music.pause();
		FlxG.switchState(new GameOverState(won, money));
		#else
		LeafyG.switchState(new GameOverState(won, money));
		#end
	}

	override public function update(elapsed:Float)
	{
		if (inCombat)
		{
			if (!combatHud.visible)
			{
				#if !wiiu
				music.resume();
				#end
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					#if wiiu
					doneFadeOut();
					#else
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
					music.pause();
					#end
				}
				else
				{
					if (combatHud.outcome == VICTORY)
					{
						#if !wiiu music.resume(); #end
						combatHud.enemy.kill();
						if (combatHud.enemy.type == BOSS)
						{
							#if wiiu
							LeafyG.switchState(new PlayState2());
							#else
							FlxG.switchState(new PlayState2());
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
							#end
						}
						#if DISCORD_ALLOWED
						DiscordClient.changePresence("WE CALL IT : PLAYSTATE CUZ FUCK YOU", null);
						#end
						#if !wiiu music.resume(); #end
					}
					else
					{
						#if !wiiu combatHud.enemy.flicker(); #end
					}
					inCombat = false;
					player.active = true;
					enemies.active = true;
					#if (mobile && !wiiu)
					virtualPad.visible = true;
					#end
				}
			}
		}
		else
		{
			#if !wiiu
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
			#else
			enemies.forEachAlive(checkEnemyVision);
			#end
		}
		
		super.update(elapsed);
		
		if (ending)
		{
			#if !wiiu music.pause(); #end
			return;
		}
	}
}
