package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
#if MOBILE_CONTROLS
import mobile.flixel.controls.MobileControls;
#end


class Player extends FlxSprite
{
	static inline var SPEED:Float = 100;

	public var left:Bool;
    public var right:Bool;
    public var up:Bool;
    public var down:Bool;

	#if MOBILE_CONTROLS
	public var manager:MobileControls;

	public function justPressed(keyName:String)
	{
		return #if flixel requestedManager.checkState(keyName, 'justPressed') #end;
	}

	public function pressed(keyName:String)
	{
		return #if flixel requestedManager.checkState(keyName, 'pressed') #end;
	}

	public function released(keyName:String)
	{
		return #if flixel requestedManager.checkState(keyName, 'justReleased') #end;
	}

	#if flixel
	public var requestedManager(get, default):Dynamic;

	@:noCompletion
	private function get_requestedManager():Dynamic
	{
		// replace this with wherever you store your MobileControls instance
		return PlayState.instance.manager;
	}
	#end
	#end

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
        loadGraphic(AssetPaths.player__png, true, 19, 38);
        setFacingFlip(LEFT, false, false);
		if (down && right)
		{
        setFacingFlip(RIGHT, false, false);
		}
		else
		{
		setFacingFlip(RIGHT, true, false);
		}
		drag.x = drag.y = 800;
        setSize(19, 38);
        offset.set(0, 1);
        animation.add("d_idle", [1]);
        animation.add("lr_idle", [5]);
        animation.add("u_idle", [9]);
        animation.add("d_walk", [0, 1, 2, 3], 6);
        animation.add("lr_walk", [4, 5, 6, 7], 6);
        animation.add("u_walk", [8, 9, 10, 11], 6);
	}


function updateMovement()
{
    up = false;
    down = false;
    left = false;
    right = false;

    #if FLX_KEYBOARD
    if (FlxG.keys.anyPressed([UP, W])) up = true;
    if (FlxG.keys.anyPressed([DOWN, S])) down = true;
    if (FlxG.keys.anyPressed([LEFT, A])) left = true;
    if (FlxG.keys.anyPressed([RIGHT, D])) right = true;
    #end

    #if MOBILE_CONTROLS
    if (pressed('up')) up = true;
    if (pressed('down')) down = true;
    if (pressed('left')) left = true;
    if (pressed('right')) right = true;
    #end

    var action = "idle";
    if ((velocity.x != 0 || velocity.y != 0) && touching == NONE)
    {
        action = "walk";
    }

    switch (facing)
    {
        case LEFT, RIGHT:
            animation.play("lr_" + action);
        case UP:
            animation.play("u_" + action);
        case DOWN:
            animation.play("d_" + action);
        case _:
    }

    if (up || down || left || right)
    {
        var newAngle:Float = 0;
        
        if (up)
        {
            newAngle = -90;
            if (left)       newAngle -= 45;
            else if (right) newAngle += 45;
            facing = UP;
        }
        else if (down)
        {
            newAngle = 90;
            if (left)       newAngle += 45;
            else if (right) newAngle -= 45;
            facing = DOWN;
        }
        else if (left)
        {
            newAngle = 180;
            facing = LEFT;
        }
        else if (right)
        {
            newAngle = 0;
            facing = RIGHT;
        }

        // Determine our velocity based on angle and speed
        velocity.setPolarDegrees(SPEED, newAngle);
    }
}

override function update(elapsed:Float)
{
	updateMovement();
	super.update(elapsed);
}
}
