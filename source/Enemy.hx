package;

import citro.object.CitroAnimate;
import citro.CitroG;

enum EnemyType { REGULAR; BOSS; }

class Enemy extends CitroAnimate {
    static inline var WALK_SPEED:Float = 40;
    static inline var CHASE_SPEED:Float = 70;

    public var type:EnemyType;
    var brain:FSM;
    var idleTimer:Float;
    var moveDirection:Float;
    public var seesPlayer:Bool;

    public var playerPosition:{x:Float, y:Float};
    public var active:Bool = true;

    public function new(x:Float, y:Float, type:EnemyType) {
        super();
        this.x = x;
        this.y = y;
        this.type = type;

        var graphic = if (type == BOSS) AssetPaths.boss__t3x else AssetPaths.enemy__t3x;
        var frameW = if (type == BOSS) 25 else 21;
        var frameH = if (type == BOSS) 46 else 40;
        var anims = new Map<String, Array<Int>>();
        
        if (type == BOSS) {
            anims.set("d_idle", [0]);
            anims.set("lr_idle", [1]);
            anims.set("u_idle", [2]);
            anims.set("d_walk", [0, 1]);
            anims.set("lr_walk", [1, 2]);
            anims.set("u_walk", [2, 0]);
        } else {
            anims.set("d_idle", [9]);
            anims.set("lr_idle", [4]);
            anims.set("u_idle", [0]);
            anims.set("d_walk", [8, 9, 10, 11]);
            anims.set("lr_walk", [4, 5, 6, 7]);
            anims.set("u_walk", [0, 1, 2, 3]);
        }
        
        trace("[Enemy] Loading graphic: " + graphic);
        loadFromT3XWithAnims(graphic, frameW, frameH, anims);
        framerate = type == BOSS ? 2 : 3;
        looped = true;
        
        if (atlasSprite == null) {
            trace("[Enemy] ERROR: atlasSprite is NULL! Graphic failed to load.");
        } else {
            trace("[Enemy] Successfully loaded. Total frames: " + atlasSprite.totalFrames);
        }
        
        playerPosition = {x: 0, y: 0};
        brain = new FSM(idle);
        idleTimer = 0;
    }

    function idle(elapsed:Float) {
        if (seesPlayer) {
            brain.activeState = chase;
        } else if (idleTimer <= 0) {
            if (Math.random() < 0.95) {
                moveDirection = CitroG.random.int(0, 8) * 45;
                var radians = moveDirection * (Math.PI / 180);
                acceleration.x = Math.cos(radians) * WALK_SPEED;
                acceleration.y = Math.sin(radians) * WALK_SPEED;
            } else {
                moveDirection = -1;
                acceleration.x = 0;
                acceleration.y = 0;
            }
            idleTimer = CitroG.random.int(1, 4);
        } else {
            idleTimer -= elapsed / 1000;
        }
    }

    function chase(elapsed:Float) {
        if (!seesPlayer) {
            brain.activeState = idle;
        } else {
            var dx = playerPosition.x - this.x;
            var dy = playerPosition.y - this.y;
            var distance = Math.sqrt(dx * dx + dy * dy);
            if (distance > 0) {
                acceleration.x = (dx / distance) * CHASE_SPEED;
                acceleration.y = (dy / distance) * CHASE_SPEED;
            }
        }
    }

    public function changeType(newType:EnemyType) {
        if (this.type != newType) {
            this.type = newType;
            var graphic = if (newType == BOSS) AssetPaths.boss__t3x else AssetPaths.enemy__t3x;
            var frameW = if (newType == BOSS) 25 else 21;
            var frameH = if (newType == BOSS) 46 else 40;
            var anims = new Map<String, Array<Int>>();
            
            if (newType == BOSS) {
                anims.set("d_idle", [0]);
                anims.set("lr_idle", [1]);
                anims.set("u_idle", [2]);
                anims.set("d_walk", [0, 1]);
                anims.set("lr_walk", [1, 2]);
                anims.set("u_walk", [2, 0]);
            } else {
                anims.set("d_idle", [9]);
                anims.set("lr_idle", [4]);
                anims.set("u_idle", [0]);
                anims.set("d_walk", [8, 9, 10, 11]);
                anims.set("lr_walk", [4, 5, 6, 7]);
                anims.set("u_walk", [0, 1, 2, 3]);
            }
            
            loadFromT3XWithAnims(graphic, frameW, frameH, anims);
            framerate = newType == BOSS ? 2 : 3;
        }
    }

    override public function update():Bool {
        if (!active || !exists) return false;
        
        var action = "idle";
        if (acceleration.x != 0 || acceleration.y != 0) {
            action = "walk";
        }
        
        var animName = "";
        if (action == "walk") {
            if (Math.abs(acceleration.y) > Math.abs(acceleration.x)) {
                animName = acceleration.y < 0 ? "u_walk" : "d_walk";
            } else {
                animName = "lr_walk";
            }
        } else {
            if (Math.abs(acceleration.y) > Math.abs(acceleration.x)) {
                animName = acceleration.y < 0 ? "u_idle" : "d_idle";
            } else {
                animName = "lr_idle";
            }
        }
        
        if (curAnim != animName) {
            play(animName);
        }

        if (atlasSprite != null) {
            if (acceleration.x < 0) {
                atlasSprite.flipX = false;
            } else if (acceleration.x > 0) {
                atlasSprite.flipX = true;
            }
        }
        
        brain.update(CitroG.deltaTime / 1000);
        return super.update();
    }
}

class FSM {
    public var activeState:Float->Void;
    public function new(initialState:Float->Void) { activeState = initialState; }
    public function update(elapsed:Float) { activeState(elapsed); }
}