package;

#if wiiu
import leafy.core.LeafySprite;
import leafy.core.LeafyG;
import leafy.group.LeafyGroup.LeafyTypedGroup;
import leafy.text.LeafyText;
import leafy.tweens.LeafyTween;
import leafy.tweens.LeafyEase;
import leafy.sound.LeafySound;
#else
import flash.filters.ColorMatrixFilter;
import flash.geom.Matrix;
import flash.geom.Point;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;
#end

enum Outcome
{
	NONE;
	ESCAPE;
	VICTORY;
	SPARED;
	DEFEAT;
}

enum Choice
{
	FIGHT;
	ACT;
	ITEM;
	SPARE;
	FLEE;
}

class CombatHUD extends #if wiiu LeafyTypedGroup<LeafySprite> #else FlxTypedGroup<FlxSprite> #end
{
	public var enemy:Enemy;
	public var playerHealth(default, null):Int;
	public var outcome(default, null):Outcome;

	#if wiiu
	var ACTTEXT:LeafyText;
	var ITEMTEXT:LeafyText;
	var SPARETEXT:LeafyText;

	var background:LeafySprite;
	var playerSprite:Player;
	var enemySprite:Enemy;

	var spareBar:Int;
	var enemyHealth:Int;
	var enemyMaxHealth:Int;
	
	var playerHealthCounter:LeafyText;
	var damages:Array<LeafyText>;
	var spare:Array<LeafyText>;
	
	var pointer:LeafySprite;
	var selected:Choice;
	var choices:Map<Choice, LeafyText>;
	var results:LeafyText;

	var alpha:Float = 0;
	var wait:Bool = true;

	var vs_susie:LeafySound;
	var fledSound:LeafySound;
	var hurtSound:LeafySound;
	var loseSound:LeafySound;
	var missSound:LeafySound;
	var selectSound:LeafySound;
	var winSound:LeafySound;
	var combatSound:LeafySound;
	var battle:LeafySound;

	var screen:LeafySprite;
	#else
	var ACTTEXT:FlxText;
	var ITEMTEXT:FlxText;
	var SPARETEXT:FlxText;

	var background:FlxSprite;
	var playerSprite:Player;
	var enemySprite:Enemy;

	var spareBar:Int;
	var enemyHealth:Int;
	var enemyMaxHealth:Int;
	var enemyHealthBar:FlxBar;
	var spareBarGame:FlxBar;
	
	var playerHealthCounter:FlxText;
	var damages:Array<FlxText>;
	var spare:Array<FlxText>;
	
	var pointer:FlxSprite;
	var selected:Choice;
	var choices:Map<Choice, FlxText>;
	var results:FlxText;

	var alpha:Float = 0;
	var wait:Bool = true;

	var vs_susie:FlxSound;
	var fledSound:FlxSound;
	var hurtSound:FlxSound;
	var loseSound:FlxSound;
	var missSound:FlxSound;
	var selectSound:FlxSound;
	var winSound:FlxSound;
	var combatSound:FlxSound;
	var battle:FlxSound;

	var screen:FlxSprite;
	#end

	public function new()
	{
		super();

		#if wiiu
		wait = true;
		active = false;
		visible = false;
		#else
		screen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.TRANSPARENT);
		var waveEffect = new FlxWaveEffect(FlxWaveMode.ALL, 4, -1, 4);
		var waveSprite = new FlxEffectSprite(screen, [waveEffect]);
		add(waveSprite);

		background = new FlxSprite().makeGraphic(220, 220, FlxColor.WHITE);
		background.drawRect(1, 1, 220, 220, FlxColor.BLACK);
		background.drawRect(1, 46, 220, 220, FlxColor.BLACK);
		background.screenCenter();
		add(background);

		playerSprite = new Player(background.x + -26, background.y + 26);
		playerSprite.animation.frameIndex = 3;
		playerSprite.active = false;
		playerSprite.facing = RIGHT;
		add(playerSprite);

		enemySprite = new Enemy(background.x + 156, background.y + 26, REGULAR);
		enemySprite.animation.frameIndex = 3;
		enemySprite.active = false;
		enemySprite.facing = DOWN;
		add(enemySprite);

		playerHealthCounter = new FlxText(0, playerSprite.y + playerSprite.height + 2, 0, "20 / 20", 8);
		playerHealthCounter.alignment = CENTER;
		playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
		add(playerHealthCounter);

		spareBarGame = new FlxBar(enemySprite.x - 15, playerHealthCounter.y - 40, LEFT_TO_RIGHT, 150, 20);
		spareBarGame.createFilledBar(FlxColor.RED, FlxColor.YELLOW, true, FlxColor.BLACK);
		spareBarGame.setRange(0, 100);
		add(spareBarGame);

		enemyHealthBar = new FlxBar(enemySprite.x - 35, playerHealthCounter.y, LEFT_TO_RIGHT, 150, 20);
		enemyHealthBar.createFilledBar(0xfffc0000, FlxColor.LIME, true, FlxColor.LIME);
		add(enemyHealthBar);

		choices = new Map();
		choices[FIGHT] = new FlxText(background.x + 5, background.y + 8, 95, "FIGHT", 22);
		choices[ACT] = new FlxText(background.x + 5, choices[FIGHT].y + choices[FIGHT].height + 8, 85, "ACT", 22);
		choices[ITEM] = new FlxText(background.x + 5, choices[ACT].y + choices[ACT].height + 8, 85, "ITEM", 22);
		choices[SPARE] = new FlxText(background.x + 5, choices[ITEM].y + choices[ITEM].height + 8, 85, "SPARE", 22);
		choices[FLEE] = new FlxText(background.x + 5, choices[SPARE].y + choices[SPARE].height + 8, 85, "FLEE", 22);
		add(choices[FIGHT]);
		add(choices[ACT]);
		add(choices[ITEM]);
		add(choices[SPARE]);
		add(choices[FLEE]);

		pointer = new FlxSprite(background.x + 10, choices[FIGHT].y + (choices[FIGHT].height / 2) - 8, AssetPaths.pointer__png);
		pointer.visible = false;
		add(pointer);

		damages = new Array<FlxText>();
		damages.push(new FlxText(0, 0, 40));
		damages.push(new FlxText(0, 0, 40));
		for (d in damages)
		{
			d.color = FlxColor.WHITE;
			d.setBorderStyle(SHADOW, FlxColor.RED);
			d.alignment = CENTER;
			d.visible = false;
			add(d);
		}

		spare = new Array<FlxText>();
		spare.push(new FlxText(0, 0, 40));
		spare.push(new FlxText(0, 0, 40));
		for (b in spare)
		{
			b.color = FlxColor.YELLOW;
			b.setBorderStyle(SHADOW, FlxColor.BLACK);
			b.alignment = CENTER;
			b.visible = false;
			add(b);
		}

		results = new FlxText(background.x + 2, background.y + 9, 116, "", 18);
		results.alignment = CENTER;
		results.color = FlxColor.YELLOW;
		results.setBorderStyle(SHADOW, FlxColor.GRAY);
		results.visible = false;
		add(results);

		forEach(function(sprite:FlxSprite)
		{
			sprite.scrollFactor.set();
			sprite.alpha = 0;
		});

		active = false;
		visible = false;

		vs_susie = FlxG.sound.load(AssetPaths.vs_susie__ogg);
		vs_susie.looped = true;
		fledSound = FlxG.sound.load(AssetPaths.fled__wav);
		hurtSound = FlxG.sound.load(AssetPaths.hurt__wav);
		loseSound = FlxG.sound.load(AssetPaths.LOSE__ogg);
		missSound = FlxG.sound.load(AssetPaths.miss__wav);
		selectSound = FlxG.sound.load(AssetPaths.select__wav);
		winSound = FlxG.sound.load(AssetPaths.win__wav);
		combatSound = FlxG.sound.load(AssetPaths.combat__wav);
		battle = FlxG.sound.load(AssetPaths.battle__ogg);
		battle.looped = true;
		#end
	}

	public function initCombat(playerHealth:Int, enemy:Enemy)
	{
		#if wiiu
		this.playerHealth = playerHealth;
		this.enemy = enemy;
		this.outcome = NONE;
		#else
		screen.drawFrame();
		var screenPixels = screen.framePixels;

		if (FlxG.renderBlit)
			screenPixels.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
		else
			screenPixels.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));

		var rc:Float = 1 / 3;
		var gc:Float = 1 / 2;
		var bc:Float = 1 / 6;
		screenPixels.applyFilter(screenPixels, screenPixels.rect, new Point(),
			new ColorMatrixFilter([rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, rc, gc, bc, 0, 0, 0, 0, 0, 1, 0]));

		if (enemy.type == REGULAR)
		{
			battle.play(true);
		}
		else if (enemy.type == BOSS)
		{
			vs_susie.play(true);
		}
		this.playerHealth = playerHealth;
		this.enemy = enemy;

		updatePlayerHealth();

		enemyMaxHealth = enemyHealth = if (enemy.type == REGULAR) 10 else 20;
		enemyHealthBar.value = 100;
		spareBarGame.value = 0;
		enemySprite.changeType(enemy.type);

		wait = true;
		results.text = "";
		pointer.visible = false;
		results.visible = false;
		outcome = NONE;
		selected = FIGHT;
		movePointer();

		visible = true;

		FlxTween.num(0, 1, .66, {ease: FlxEase.circOut, onComplete: finishFadeIn}, updateAlpha);
		#end
	}

	function updateAlpha(alpha:Float)
	{
		this.alpha = alpha;
		#if !wiiu
		forEach(function(sprite) sprite.alpha = alpha);
		#end
	}

	function finishFadeIn(_)
	{
		#if !wiiu
		active = true;
		wait = false;
		pointer.visible = true;
		selectSound.play();
		#end
	}

	function finishFadeOut(_)
	{
		active = false;
		visible = false;
	}

	function updatePlayerHealth()
	{
		#if !wiiu
		playerHealthCounter.text = playerHealth + " / 20";
		playerHealthCounter.x = playerSprite.x + 4 - (playerHealthCounter.width / 2);
		#end
	}

	override public function update(elapsed:Float)
	{
		#if !wiiu
		if (!wait)
		{
			updateKeyboardInput();
			updateTouchInput();
		}
		super.update(elapsed);
		#end
	}

	function updateKeyboardInput()
	{
		#if (FLX_KEYBOARD && !wiiu)
		var up:Bool = false;
		var down:Bool = false;
		var fire:Bool = false;

		if (FlxG.keys.anyJustReleased([SPACE, Z, ENTER]))
		{
			fire = true;
		}
		else if (FlxG.keys.anyJustReleased([W, UP]))
		{
			up = true;
		}
		else if (FlxG.keys.anyJustReleased([S, DOWN]))
		{
			down = true;
		}

		if (fire)
		{
			selectSound.play();
			makeChoice();
		}
		else if (up || down)
		{
			selected = switch (selected) {
				case FIGHT: if (up) FLEE else ACT;
				case ACT: if (up) FIGHT else ITEM;
				case ITEM: if (up) ACT else SPARE;
				case SPARE: if (up) ITEM else FLEE;
				case FLEE: if (up) SPARE else FIGHT;
			};
			selectSound.play();
			movePointer();
		}
		#end
	}

	function updateTouchInput()
	{
		#if (FLX_TOUCH && !wiiu)
		for (touch in FlxG.touches.justReleased())
		{
			for (choice in choices.keys())
			{
				var text = choices[choice];
				if (touch.overlaps(text))
				{
					selectSound.play();
					selected = choice;
					movePointer();
					makeChoice();
					return;
				}
			}
		}
		#end
	}

	function movePointer()
	{
		#if !wiiu
		pointer.y = choices[selected].y + (choices[selected].height / 2) - 8;
		#end
	}

	function makeChoice()
	{
		#if !wiiu
		pointer.visible = false;
		switch (selected)
		{
			case FIGHT:
				if (FlxG.random.bool(85))
				{
					damages[1].text = "5";
					FlxTween.tween(enemySprite, {x: enemySprite.x + 4}, 0.1, {
						onComplete: function(_) { FlxTween.tween(enemySprite, {x: enemySprite.x - 4}, 0.1); }
					});
					hurtSound.play();
					enemyHealth--;
					enemyHealthBar.value = (enemyHealth / enemyMaxHealth) * 30;
				}
				else
				{
					damages[1].text = "MISS!";
					missSound.play();
				}

				damages[1].x = enemySprite.x + 2 - (damages[1].width / 2);
				damages[1].y = enemySprite.y + 4 - (damages[1].height / 2);
				damages[1].alpha = 0;
				damages[1].visible = true;

				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
			
			case ACT:
				spareBar++;
				spareBarGame.value += 15;
				
				spare[1].x = enemySprite.x + 2 - (spare[1].width / 2);
				spare[1].y = enemySprite.y + 4 - (spare[1].height / 2);
				spare[1].alpha = 0;
				spare[1].visible = true;

				if (enemyHealth > 0)
				{
					enemyAttack();
				}

				FlxTween.num(spare[0].y, spare[0].y - 12, 1, {ease: FlxEase.circOut}, updateSpareY);
				FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneSpareIn}, updateSpareAlpha);
			
			case ITEM:
				var ITEMTEXT = new flixel.text.FlxText(10, 10, 100, "USED AN ITEM ?");
				add(ITEMTEXT);
				background.visible = false;

				if (enemyHealth > 0)
				{
					enemyAttack();
					background.visible = true;
					remove(ITEMTEXT);
				}

			case SPARE:
				var SPARETEXT = new flixel.text.FlxText(10, 10, 100, "SPARED ?");
				add(SPARETEXT);
				background.visible = false;

				if (enemyHealth > 0)
				{
					enemyAttack();
					background.visible = true;
					remove(SPARETEXT);
				}

				if (spareBar == 100)
				{
					enemyAttack();
					outcome = SPARED;
					results.text = "SPARED!";
					fledSound.play();
					results.visible = true;
					results.alpha = 0;
					FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
				}

			case FLEE:
				if (FlxG.random.bool(50))
				{
					if (enemy.type == REGULAR) { battle.stop(); }
					else if (enemy.type == BOSS) { vs_susie.stop(); }
					outcome = ESCAPE;
					results.text = "ESCAPED!";
					fledSound.play();
					results.visible = true;
					results.alpha = 0;
					FlxTween.tween(results, {alpha: 1}, .66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
				}
				else
				{
					enemyAttack();
					FlxTween.num(damages[0].y, damages[0].y - 12, 1, {ease: FlxEase.circOut}, updateDamageY);
					FlxTween.num(0, 1, .2, {ease: FlxEase.circInOut, onComplete: doneDamageIn}, updateDamageAlpha);
				}
		}
		wait = true;
		#end
	}

	function enemyAttack()
	{
		#if !wiiu
		if (FlxG.random.bool(30))
		{
			FlxG.camera.flash(FlxColor.WHITE, .2);
			FlxG.camera.shake(0.01, 0.2);
			hurtSound.play();
			damages[0].text = "1";
			playerHealth--;
			updatePlayerHealth();
		}
		else
		{
			damages[0].text = "MISS!";
			missSound.play();
		}

		damages[0].x = playerSprite.x + 2 - (damages[0].width / 2);
		damages[0].y = playerSprite.y + 4 - (damages[0].height / 2);
		damages[0].alpha = 0;
		damages[0].visible = true;
		#end
	}

	function updateDamageY(damageY:Float)
	{
		#if !wiiu
		damages[0].y = damages[1].y = damageY;
		#end
	}

	function updateDamageAlpha(damagesAlpha:Float)
	{
		#if !wiiu
		damages[0].alpha = damages[1].alpha = damagesAlpha;
		#end
	}

	function updateSpareY(spareY:Float)
	{
		#if !wiiu
		spare[0].y = spare[1].y = spareY;
		#end
	}

	function updateSpareAlpha(spareAlpha:Float)
	{
		#if !wiiu
		spare[0].alpha = spare[1].alpha = spareAlpha;
		#end
	}

	function doneDamageIn(_)
	{
		#if !wiiu
		FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneDamageOut}, updateDamageAlpha);
		#end
	}

	function doneSpareIn(_)
	{
		#if !wiiu
		FlxTween.num(1, 0, .66, {ease: FlxEase.circInOut, startDelay: 1, onComplete: doneSpareOut}, updateSpareAlpha);
		#end
	}

	function doneResultsIn(_)
	{
		#if !wiiu
		FlxTween.num(1, 0, .66, {ease: FlxEase.circOut, onComplete: finishFadeOut, startDelay: 1}, updateAlpha);
		#end
	}

	function doneDamageOut(_)
	{
		#if !wiiu
		damages[0].visible = false;
		damages[1].visible = false;
		damages[0].text = "";
		damages[1].text = "";

		if (playerHealth <= 0)
		{
			if (enemy.type == REGULAR) { battle.stop(); }
			else if (enemy.type == BOSS) { vs_susie.stop(); }
			outcome = DEFEAT;
			loseSound.play();
			results.text = "DEFEAT!";
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else if (enemyHealth <= 0)
		{
			if (enemy.type == REGULAR) { battle.stop(); }
			else if (enemy.type == BOSS) { vs_susie.stop(); }
			outcome = VICTORY;
			winSound.play();
			results.text = "VICTORY!";
			results.visible = true;
			results.alpha = 0;
			FlxTween.tween(results, {alpha: 1}, 0.66, {ease: FlxEase.circInOut, onComplete: doneResultsIn});
		}
		else
		{
			wait = false;
			pointer.visible = true;
		}
		#end
	}

	function doneSpareOut(_)
	{
		#if !wiiu
		spare[0].visible = false;
		spare[1].visible = false;
		spare[0].text = "";
		spare[1].text = "";
		wait = false;
		pointer.visible = true;
		#end
	}
}
