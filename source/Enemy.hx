package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
using flixel.util.FlxSpriteUtil;

enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends FlxSprite
{
	static inline var WALK_SPEED:Float = 40;
	static inline var CHASE_SPEED:Float = 70;

	public var type:EnemyType;
    var brain:FSM;
    var idleTimer:Float;
    var moveDirection:Float;
    public var seesPlayer:Bool;
	public var playerPosition:FlxPoint;

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
        if (type == BOSS)        
        {
        loadGraphic(graphic, true, 25, 46);
        }
        else if (type == REGULAR)
		{
			loadGraphic(graphic, true, 21, 40);
		}
		else if (type == REGULAR && facing == LEFT || facing == RIGHT)
		{
			loadGraphic(graphic, true, 19, 40);
		}
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		animation.add("d_idle", [9]);
		animation.add("lr_idle", [4]);
		animation.add("u_idle", [0]);
		animation.add("d_walk", [8, 9, 10, 11], 6);
		animation.add("lr_walk", [4, 5, 6, 7], 6);
		animation.add("u_walk", [0, 1, 2, 3], 6);
		drag.x = drag.y = 10;
		if (type == BOSS)
        {
			setSize(25, 46);
			offset.set(-2, 2);
		}
        else
        {
			setSize(21, 41);
			offset.set(0, 2);
		}
		offset.x = 4;
		offset.y = 8;
        brain = new FSM(idle);
        idleTimer = 0;
        playerPosition = FlxPoint.get();
	}

    function idle(elapsed:Float)
    {
	if (seesPlayer)
	{
		brain.activeState = chase;
	}
	else if (idleTimer <= 0)
	{
		// 95% chance to move
		if (FlxG.random.bool(95))
		{
			moveDirection = FlxG.random.int(0, 8) * 45;

			velocity.setPolarDegrees(WALK_SPEED, moveDirection);
		}
		else
		{
			moveDirection = -1;
			velocity.x = velocity.y = 0;
		}
		idleTimer = FlxG.random.int(1, 4);
	}
	else
		idleTimer -= elapsed;
	
    }

    function chase(elapsed:Float)
    {
	if (!seesPlayer)
	{
		brain.activeState = idle;
	}
	else
	{
		FlxVelocity.moveTowardsPoint(this, playerPosition, CHASE_SPEED);
	}
    }
	public function changeType(type:EnemyType)
	{
	if (this.type != type)
	{
		this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, 16, 16);
	}
	}
	override public function update(elapsed:Float)
	{
		if (this.isFlickering())
		return;
		var action = "idle";
		if (velocity.x != 0 || velocity.y != 0)
		{
			action = "walk";
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					facing = LEFT;
				else
					facing = RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = UP;
				else
					facing = DOWN;
			}
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
        brain.update(elapsed);
		super.update(elapsed);
	}
}