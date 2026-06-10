package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;

class Player extends FlxSprite
{
	static inline var SPEED:Float = 100;

	public var up:Bool<dynamic>;
	public var down:Bool;
	public var left:Bool;
	public var right:Bool;

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
	#if FLX_KEYBOARD
    up = FlxG.keys.anyPressed([UP, W]);
    down = FlxG.keys.anyPressed([DOWN, S]);
    left = FlxG.keys.anyPressed([LEFT, A]);
    right = FlxG.keys.anyPressed([RIGHT, D]);
	#end

	#if mobile
	var virtualPad = PlayState.virtualPad;
	up = up || virtualPad.buttonUp.justPressed;
	down = down || virtualPad.buttonDown.justPressed;
	left  = left || virtualPad.buttonLeft.justPressed;
	right = right || virtualPad.buttonRight.justPressed;
	#end

    var action = "idle";
    // check if the player is moving, and not walking into walls
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

    if (up && down)
	up = down = false;
    if (left && right)
	left = right = false;
    if (up || down || left || right)
    {
	var newAngle:Float = 0;
	if (up)
	{
		newAngle = -90;
		if (left)
			newAngle -= 45;
		else if (right)
			newAngle += 45;
		facing = UP;
	}
	else if (down)
	{
		newAngle = 90;
		if (left)
			newAngle += 45;
		else if (right)
			newAngle -= 45;
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

	// determine our velocity based on angle and speed
	velocity.setPolarDegrees(SPEED, newAngle);
}
}
override function update(elapsed:Float)
{
	updateMovement();
	super.update(elapsed);
}
}
