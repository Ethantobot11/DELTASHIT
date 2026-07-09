package;

#if wiiu
import leafy.core.LeafySprite;
import leafy.core.LeafyG;
import leafy.math.LeafyPoint;
#else
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
using flixel.util.FlxSpriteUtil;
#end

enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends #if wiiu LeafySprite #else FlxSprite #end
{
	static inline var WALK_SPEED:Float = 40;
	static inline var CHASE_SPEED:Float = 70;

	public var type:EnemyType;
	var brain:FSM;
	var idleTimer:Float;
	var moveDirection:Float;
	public var seesPlayer:Bool;
	
	#if wiiu
	public var playerPosition:LeafyPoint;
	#else
	public var playerPosition:FlxPoint;
	#end

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		this.type = type;

		#if wiiu
		// Wii U asset path definition via direct file target mapping strings
		var graphic = if (type == BOSS) "assets/images/boss.png" else "assets/images/enemy.png";
		if (type == BOSS)        
		{
			loadGraphic(graphic, true, 25, 46);
			setSize(25, 46);
		}
		else
		{
			loadGraphic(graphic, true, 21, 40); 
			setSize(21, 41);
		}
		playerPosition = new LeafyPoint();
		#else
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		if (type == BOSS)        
		{
			loadGraphic(graphic, true, 25, 46);
			setSize(25, 46);
			offset.set(-2, 2);
		}
		else
		{
			loadGraphic(graphic, true, 21, 40); 
			setSize(21, 41);
			offset.set(0, 2);
		}
		playerPosition = FlxPoint.get();
		#end
		
		#if !wiiu
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		#end
		
		animation.add("d_idle", [9]);
		animation.add("lr_idle", [4]);
		animation.add("u_idle", [0]);
		animation.add("d_walk", [8, 9, 10, 11], 4);
		animation.add("lr_walk", [4, 5, 6, 7], 5);
		animation.add("u_walk", [0, 1, 2, 3], 5);
		
		#if !wiiu
		drag.x = drag.y = 10;
		#end

		brain = new FSM(idle);
		idleTimer = 0;
	}

	function idle(elapsed:Float)
	{
		if (seesPlayer)
		{
			brain.activeState = chase;
		}
		else if (idleTimer <= 0)
		{
			#if wiiu
			if ((Math.random() * 100) < 95)
			{
				moveDirection = Math.floor(Math.random() * 9) * 45;
				var radians = moveDirection * (Math.PI / 180);
				velocity.x = Math.cos(radians) * WALK_SPEED;
				velocity.y = Math.sin(radians) * WALK_SPEED;
			}
			else
			{
				moveDirection = -1;
				velocity.x = velocity.y = 0;
			}
			idleTimer = Math.floor(Math.random() * 4) + 1;
			#else
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
			#end
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
			#if wiiu
			var dx = playerPosition.x - this.x;
			var dy = playerPosition.y - this.y;
			var distance = Math.sqrt(dx * dx + dy * dy);
			if (distance > 0) {
				velocity.x = (dx / distance) * CHASE_SPEED;
				velocity.y = (dy / distance) * CHASE_SPEED;
			}
			#else
			FlxVelocity.moveTowardsPoint(this, playerPosition, CHASE_SPEED);
			#end
		}
	}

	public function changeType(type:EnemyType)
	{
		if (this.type != type)
		{
			this.type = type;
			#if wiiu
			var graphic = if (type == BOSS) "assets/images/boss.png" else "assets/images/enemy.png";
			if (type == BOSS)        
			{
				loadGraphic(graphic, true, 25, 46);
				setSize(25, 46);
			}
			else if (type == REGULAR)
			{
				loadGraphic(graphic, true, 21, 40);
				setSize(21, 41);
			}
			#else
			var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
			if (type == BOSS)        
			{
				loadGraphic(graphic, true, 25, 46);
				setSize(25, 46);
				offset.set(-2, 2);
			}
			else if (type == REGULAR)
			{
				loadGraphic(graphic, true, 21, 40);
				setSize(21, 41);
				offset.set(0, 2);
			}
			else if (type == REGULAR && facing == LEFT || facing == RIGHT)
			{
				loadGraphic(graphic, true, 19, 40);
				setSize(19, 40);
				offset.set(0, 2);
			}
			#end
		}
	}

	override public function update(elapsed:Float)
	{
		#if !wiiu
		if (this.isFlickering())
			return;
		#end

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
