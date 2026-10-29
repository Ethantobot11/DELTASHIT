package;

import citro.object.CitroAnimate;
import citro.CitroG;
import haxe3ds.services.HID;

class Player extends CitroAnimate {
    static inline var SPEED:Float = 100;

    public var up:Bool;
    public var down:Bool;
    public var left:Bool;
    public var right:Bool;
    public var active:Bool = true;
    
    private var facing:String = "down";

    public function new(x:Float = 0, y:Float = 0) {
        super();
        this.x = x;
        this.y = y;
        var anims = new Map<String, Array<Int>>();
        anims.set("d_idle", [1]);
        anims.set("lr_idle", [5]);
        anims.set("u_idle", [9]);
        anims.set("d_walk", [0, 1, 2, 3]);
        anims.set("lr_walk", [4, 5, 6, 7]);
        anims.set("u_walk", [8, 9, 10, 11]);
        loadFromT3XWithAnims("romfs:/assets/images/player.t3x", 19, 38, anims);
        framerate = 6;
        looped = true;
    }

    function updateMovement() {
        up = HID.keyHeld(HIDKey.UP);
        down = HID.keyHeld(HIDKey.DOWN);
        left = HID.keyHeld(HIDKey.LEFT);
        right = HID.keyHeld(HIDKey.RIGHT);

        var moving = (acceleration.x != 0 || acceleration.y != 0);
        var animName = "";

        if (up || down || left || right) {
            var newAngle:Float = 0;
            if (up) {
                newAngle = -90;
                if (left) newAngle -= 45;
                else if (right) newAngle += 45;
                facing = "up";
            } else if (down) {
                newAngle = 90;
                if (left) newAngle += 45;
                else if (right) newAngle -= 45;
                facing = "down";
            } else if (left) {
                newAngle = 180;
                facing = "left";
            } else if (right) {
                newAngle = 0;
                facing = "right";
            }

            var radians = newAngle * (Math.PI / 180);
            acceleration.x = Math.cos(radians) * SPEED;
            acceleration.y = Math.sin(radians) * SPEED;
            
            if (facing == "down") animName = moving ? "d_walk" : "d_idle";
            else if (facing == "up") animName = moving ? "u_walk" : "u_idle";
            else animName = moving ? "lr_walk" : "lr_idle";
        } else {
            acceleration.x = 0;
            acceleration.y = 0;
            if (facing == "down") animName = "d_idle";
            else if (facing == "up") animName = "u_idle";
            else animName = "lr_idle";
        }
        
        if (curAnim != animName) {
            play(animName);
        }
    }

    override public function update():Bool {
        if (!active || !exists) return false;
        updateMovement();
        return super.update();
    }
}