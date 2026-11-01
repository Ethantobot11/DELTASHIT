package;

import citro.CitroG;
import citro.editors.ogmo.CitroOgmo3Loader;
import citro.object.CitroCamera;
import citro.object.CitroGroup;
import citro.object.CitroObject;
import citro.object.CitroSprite;
import citro.object.CitroTilemap;
import citro.math.CitroMath;
import citro.state.CitroState;
import haxe3ds.services.HID;

class PlayState2 extends CitroState {
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
        camera.bottom = false;
        add(camera);

        music = CitroG.sound.load(AssetPaths.boxing_game__cwav);
        music.looped = true;
        music.play();
        
        map = new CitroOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
        walls = map.loadTilemap(AssetPaths.tiles__t3x, "walls", 16);
        walls.bottom = false;
        walls.camera = camera;
        camera.add(walls); 

        enemies = new CitroGroup();
        enemies.bottom = false;
        camera.add(enemies);

        coins = new CitroGroup();
        coins.bottom = false;
        camera.add(coins);

        player = new Player();
        player.setWalls(walls);
        map.loadEntities(placeEntities);
        for (enemy in enemies.members) { if (Std.is(enemy, Enemy)) { cast(enemy, Enemy).setWalls(walls); } }
        player.bottom = false;
        camera.add(player);
        
        camera.follow(player, true);
        camera.target = player;

        hud = new HUD();
        hud.bottom = false;
        add(hud);    
        
        combatHud = new CombatHUD();
        combatHud.bottom = false;
        add(combatHud);

        super.create();
    }
    function placeEntities(entity:Dynamic) {
        var x:Float = entity.x;
        var y:Float = entity.y;
        switch (entity.name) {
            case "player":
                player.x = x; player.y = y;
            case "coin": 
                coins.add(new Coin(x + 4, y + 4));
            case "enemy": 
                enemies.add(new Enemy(x + 4, y, REGULAR));
            case "boss": 
                enemies.add(new Enemy(x + 4, y, BOSS));
            default:
                trace("[PlayState] Unknown entity: " + entity.name);
        }
    }

    function playerTouchCoin(coin:Coin) {
        if (player.exists && coin.exists) {
            money++;
            hud.updateHUD(health, money);
            coin.kill();
        }
    }

    function hasLineOfSight(fromX:Float, fromY:Float, toX:Float, toY:Float, walls:CitroTilemap):Bool {
        var steps = Std.int(Math.sqrt(Math.pow(toX - fromX, 2) + Math.pow(toY - fromY, 2)) / 8);
        for (i in 0...steps) {
            var t = i / steps;
            var checkX = fromX + (toX - fromX) * t;
            var checkY = fromY + (toY - fromY) * t;
            if (walls.checkTileCollision(checkX, checkY, 1, 1)) {
                return false;
            }
        }
        return true;
    }

    function checkEnemyVision(enemy:Enemy) {
        var dx = player.x - enemy.x;
        var dy = player.y - enemy.y;
        var dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 150 && hasLineOfSight(enemy.x, enemy.y, player.x, player.y, walls)) {
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

    private function separate(obj1:CitroObject, obj2:CitroObject, condition:Bool = true):Bool
    {
        if (!condition || !CitroG.overlaps(obj1, obj2))
        {
            return false;
        }

        var overlapX1 = (obj1.x + (obj1.width * obj1.scale.x)) - obj2.x;
        var overlapX2 = (obj2.x + (obj2.width * obj2.scale.x)) - obj1.x;
        var overlapY1 = (obj1.y + (obj1.height * obj1.scale.y)) - obj2.y;
        var overlapY2 = (obj2.y + (obj2.height * obj2.scale.y)) - obj1.y;

        var minOverlapX = overlapX1 < overlapX2 ? overlapX1 : overlapX2;
        var minOverlapY = overlapY1 < overlapY2 ? overlapY1 : overlapY2;

        if (minOverlapX < minOverlapY)
        {
            if (overlapX1 < overlapX2)
            {
                obj1.x -= overlapX1;
            }
            else
            {
                obj1.x += overlapX2;
            }
        }
        else
        {
            if (overlapY1 < overlapY2)
            {
                obj1.y -= overlapY1;
            }
            else
            {
                obj1.y += overlapY2;
            }
        }

        return true;
    }

    override public function update(delta:Int):Void {
        //separate(player, walls , true);
        //separate(enemies, walls, true);
        
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
