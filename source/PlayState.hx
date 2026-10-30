package;

import citro.CitroG;
import citro.editors.ogmo.CitroOgmo3Loader;
import citro.object.CitroCamera;
import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.object.CitroTilemap;
import citro.state.CitroState;
import haxe3ds.services.HID;

class PlayState extends CitroState {
    var player:Player;
    var hud:HUD;
    var money:Int = 0;
    var health:Int = 20;
    var inCombat:Bool = false;
    var combatHud:CombatHUD;
    var ending:Bool;
    var won:Bool;

    var map:CitroOgmo3Loader;
    var walls:CitroTilemap;
    var coins:CitroGroup;
    var enemies:CitroGroup;
    var camera:CitroCamera;

    override public function create() {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("WE CALL IT : PLAYSTATE CUZ FUCK YOU", null);
        #end

        camera = new CitroCamera();
        add(camera);

        map = new CitroOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
        walls = map.loadTilemap(AssetPaths.tiles__t3x, "walls", 16);
        camera.add(walls); 

        enemies = new CitroGroup();
        camera.add(enemies);

        coins = new CitroGroup();
        camera.add(coins);

        player = new Player();
        map.loadEntities(placeEntities);
        camera.add(player);

        camera.follow(player, true);
        camera.target = player;

        hud = new HUD();
        add(hud);    
        
        combatHud = new CombatHUD();
        add(combatHud);

        super.create();
    }

    function placeEntities(entity:Dynamic) {
        var x:Float = entity.x;
        var y:Float = entity.y;
        switch (entity.name) {
            case "player": player.x = x; player.y = y;
            case "coin": coins.add(new Coin(x + 4, y + 4));
            case "enemy": 
                enemies.add(new Enemy(x + 4, y, REGULAR));
            case "boss": 
                enemies.add(new Enemy(x + 4, y, BOSS));
        }
    }

    function playerTouchCoin(coin:Coin) {
        if (player.exists && coin.exists) {
            money++;
            hud.updateHUD(health, money);
            coin.kill();
        }
    }

    function checkEnemyVision(enemy:Enemy) {
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
    }

    function playerTouchEnemy(enemy:Enemy) {
        if (player.exists && enemy.exists && !inCombat) {
            startCombat(enemy);
        }
    }

    function startCombat(enemy:Enemy) {
        #if DISCORD_ALLOWED
        DiscordClient.changePresence("FIGHTING", null);
        #end
        inCombat = true;
        player.active = false;
        enemies.forEach(function(e:Dynamic) { if(e.exists) e.active = false; });
        combatHud.initCombat(health, enemy);
    }

    override public function update(delta:Int):Void {
        if (inCombat) {
            if (!combatHud.exists) {
                health = combatHud.playerHealth;
                hud.updateHUD(health, money);
                
                if (combatHud.outcome == DEFEAT) {
                    ending = true;
                    CitroG.switchState(new GameOverState(won, money));
                } else if (combatHud.outcome == VICTORY) {
                    combatHud.enemy.exists = false;
                    if (combatHud.enemy.type == BOSS) {
                        won = true;
                        ending = true;
                        CitroG.switchState(new GameOverState(won, money));
                    } else {
                        inCombat = false;
                        player.active = true;
                        enemies.forEach(function(e:Dynamic) { if(e.exists) e.active = true; });
                    }
                } else {
                    inCombat = false;
                    player.active = true;
                    enemies.forEach(function(e:Dynamic) { if(e.exists) e.active = true; });
                }
            }
        } else {
            for (enemy in enemies.members) {
                if (enemy.exists && CitroG.overlaps(player, enemy)) {
                    playerTouchEnemy(cast enemy);
                }
            }
            for (coin in coins.members) {
                if (coin.exists && CitroG.overlaps(player, coin)) {
                    playerTouchCoin(cast coin);
                }
            }
            enemies.forEach(function(e:Dynamic) { if(e.exists) checkEnemyVision(cast e); });
        }
        
        super.update(delta);
    }
}