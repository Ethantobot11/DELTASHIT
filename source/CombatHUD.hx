package;

import citro.CitroG;
import citro.backend.CitroColor;
import citro.backend.CitroSound;
import citro.backend.CitroTween.CitroEase;
import citro.backend.CitroTween;
import citro.object.CitroBar;
import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.object.CitroText;
import haxe3ds.services.HID;
import Enemy.EnemyType;

enum Outcome { NONE; ESCAPE; VICTORY; SPARED; DEFEAT; }
enum Choice { FIGHT; ACT; ITEM; SPARE; FLEE; }

class CombatHUD extends CitroGroup
{
    public var enemy:Enemy;
    public var playerHealth(default, null):Int;
    public var outcome(default, null):Outcome;

    var background:CitroSprite;
    var playerSprite:Player;
    var enemySprite:Enemy;
    var spareBar:Int;
    var enemyHealth:Int;
    var enemyMaxHealth:Int;
    var enemyHealthBar:CitroBar;
    var spareBarGame:CitroBar;
    var playerHealthCounter:CitroText;
    var damages:Array<CitroText>;
    var spare:Array<CitroText>;
    var pointer:CitroSprite;
    var selected:Choice;
    var choices:Map<Choice, CitroText>;
    var results:CitroText;
    var wait:Bool = true;

    var vs_susie:CitroSound;
    var fledSound:CitroSound;
    var hurtSound:CitroSound;
    var loseSound:CitroSound;
    var missSound:CitroSound;
    var selectSound:CitroSound;
    var winSound:CitroSound;
    var combatSound:CitroSound;
    var battle:CitroSound;
    var screenFlash:CitroSprite;

    public function new()
    {
        super();
        wait = true;
        exists = false;
        visible = false;

        screenFlash = new CitroSprite(0, 0);
        screenFlash.makeGraphic(400, 240, 0xFFFFFFFF);
        screenFlash.alpha = 0;
        add(screenFlash);

        background = new CitroSprite(0, 0);
        background.makeGraphic(220, 130, 0xFFFFFFFF);
        background.x = (400 - 220) / 2;
        background.y = 10;
        add(background);

        playerSprite = new Player(background.x - 26, background.y + 26);
        playerSprite.active = false;
        add(playerSprite);

        enemySprite = new Enemy(background.x + 156, background.y + 26, EnemyType.REGULAR);
        enemySprite.active = false;
        add(enemySprite);

        playerHealthCounter = new CitroText(0, playerSprite.y + playerSprite.height + 2, "20 / 20");
        playerHealthCounter.alignment = CENTER;
        add(playerHealthCounter);

        spareBarGame = new CitroBar(enemySprite.x - 15, playerHealthCounter.y - 40, 150, 20);
        spareBarGame.min = 0;
        spareBarGame.max = 100;
        spareBarGame.value = 0;
        add(spareBarGame);

        enemyHealthBar = new CitroBar(enemySprite.x - 35, playerHealthCounter.y, 150, 20);
        enemyHealthBar.min = 0;
        enemyHealthBar.max = 100;
        enemyHealthBar.value = 100;
        add(enemyHealthBar);

        choices = new Map();
        var buttonX:Float = (320 - 95) / 2;
        var buttonY:Float = 180;
        
        choices[FIGHT] = new CitroText(buttonX, buttonY, "FIGHT");
        choices[ACT] = new CitroText(buttonX, buttonY + 24, "ACT");
        choices[ITEM] = new CitroText(buttonX, buttonY + 48, "ITEM");
        choices[SPARE] = new CitroText(buttonX, buttonY + 72, "SPARE");
        choices[FLEE] = new CitroText(buttonX, buttonY + 96, "FLEE");
        
        for (choice in choices) {
            choice.bottom = true;
            add(choice);
        }

        pointer = new CitroSprite(buttonX - 10, choices[FIGHT].y + 4);
        pointer.loadGraphic("romfs:/assets/images/pointer.t3x");
        pointer.bottom = true;
        pointer.visible = false;
        add(pointer);

        damages = [new CitroText(0, 0, ""), new CitroText(0, 0, "")];
        for (d in damages)
        {
            d.color = 0xFFFFFFFF;
            d.setBorderStyle(0xFFFF0000, 1, SHADOW);
            d.alignment = CENTER;
            d.visible = false;
            add(d);
        }

        spare = [new CitroText(0, 0, ""), new CitroText(0, 0, "")];
        for (b in spare)
        {
            b.color = 0xFFFFFF00;
            b.setBorderStyle(0xFF000000, 1, SHADOW);
            b.alignment = CENTER;
            b.visible = false;
            add(b);
        }

        results = new CitroText(background.x + 2, background.y + 9, "");
        results.alignment = CENTER;
        results.color = 0xFFFFFF00;
        results.setBorderStyle(0xFF808080, 1, SHADOW);
        results.visible = false;
        add(results);

        for (member in members)
        {
            member.alpha = 0;
        }

        vs_susie = CitroG.sound.load(AssetPaths.vs_susie__cwav);
        vs_susie.looped = true;
        fledSound = CitroG.sound.load(AssetPaths.fled__cwav);
        hurtSound = CitroG.sound.load(AssetPaths.hurt__cwav);
        loseSound = CitroG.sound.load(AssetPaths.LOSE__cwav);
        missSound = CitroG.sound.load(AssetPaths.miss__cwav);
        selectSound = CitroG.sound.load(AssetPaths.select__cwav);
        winSound = CitroG.sound.load(AssetPaths.win__cwav);
        combatSound = CitroG.sound.load(AssetPaths.combat__cwav);
        battle = CitroG.sound.load(AssetPaths.battle__cwav);
        battle.looped = true;
    }

    public function initCombat(playerHealth:Int, enemy:Enemy)
    {
        this.playerHealth = playerHealth;
        this.enemy = enemy;
        this.outcome = NONE;
        updatePlayerHealth();
        enemyMaxHealth = enemyHealth = (enemy.type == BOSS) ? 20 : 10;
        enemyHealthBar.value = 100;
        spareBarGame.value = 0;
        enemySprite.changeType(enemy.type);

        wait = true;
        results.text = "";
        pointer.visible = false;
        results.visible = false;
        selected = FIGHT;
        movePointer();
        visible = true;

        CitroTween.tweenObject(this, {alpha: 1}, 0.66, {ease: CitroEase.CIRC_OUT, onComplete: finishFadeIn});
        if (enemy.type == REGULAR)
            battle.play(true);
        else if (enemy.type == BOSS)
            vs_susie.play(true);
    }

    function updateAlpha(alpha:Float)
    {
        this.alpha = alpha;
        for (member in members)
            member.alpha = alpha;
    }

    function finishFadeIn()
    {
        exists = true;
        wait = false;
        pointer.visible = true;
        selectSound.play();
    }

    function updatePlayerHealth()
    {
        playerHealthCounter.text = playerHealth + " / 20";
    }

    override public function update():Bool
    {
        if (!wait)
        {
            updateInput();
        }
        return super.update();
    }

    function updateInput()
    {
        var up = false, down = false, fire = false;
        if (HID.keyPressed(HIDKey.A | HIDKey.B | HIDKey.START))
            fire = true;
        else if (HID.keyPressed(HIDKey.UP))
            up = true;
        else if (HID.keyPressed(HIDKey.DOWN))
            down = true;

        if (fire)
        {
            selectSound.play();
            makeChoice();
        }
        else if (up || down)
        {
            selected = switch (selected)
            {
                case FIGHT: if (up) FLEE else ACT;
                case ACT: if (up) FIGHT else ITEM;
                case ITEM: if (up) ACT else SPARE;
                case SPARE: if (up) ITEM else FLEE;
                case FLEE: if (up) SPARE else FIGHT;
            };
            selectSound.play();
            movePointer();
        }
    }

    function movePointer()
    {
        pointer.y = choices[selected].y + 4;
    }

    function makeChoice()
    {
        pointer.visible = false;
        switch (selected)
        {
            case FIGHT:
                if (Math.random() < 0.85)
                {
                    damages[1].text = "5";
                    CitroTween.tweenObject(enemySprite, {x: enemySprite.x + 4}, 0.1, {
                        onComplete: function()
                        {
                            CitroTween.tweenObject(enemySprite, {x: enemySprite.x - 4}, 0.1);
                        }
                    });
                    hurtSound.play();
                    enemyHealth--;
                    enemyHealthBar.value = (enemyHealth / enemyMaxHealth) * 100;
                }
                else
                {
                    damages[1].text = "MISS!";
                    missSound.play();
                }
                damages[1].x = enemySprite.x + 2;
                damages[1].y = enemySprite.y + 4;
                damages[1].alpha = 0;
                damages[1].visible = true;
                if (enemyHealth > 0)
                    enemyAttack();
                CitroTween.tweenNumber(damages[0].y, damages[0].y - 12, 1, {ease: CitroEase.CIRC_OUT, onUpdate: function(v)
                {
                    damages[0].y = damages[1].y = v;
                }});
                CitroTween.tweenNumber(0, 1, 0.2, {ease: CitroEase.CIRC_INOUT, onComplete: doneDamageIn, onUpdate: function(v)
                {
                    damages[0].alpha = damages[1].alpha = v;
                }});

            case ACT:
                spareBar++;
                spareBarGame.value += 15;
                spare[1].x = enemySprite.x + 2;
                spare[1].y = enemySprite.y + 4;
                spare[1].alpha = 0;
                spare[1].visible = true;
                if (enemyHealth > 0)
                    enemyAttack();
                CitroTween.tweenNumber(spare[0].y, spare[0].y - 12, 1, {ease: CitroEase.CIRC_OUT, onUpdate: function(v)
                {
                    spare[0].y = spare[1].y = v;
                }});
                CitroTween.tweenNumber(0, 1, 0.2, {ease: CitroEase.CIRC_INOUT, onComplete: doneSpareIn, onUpdate: function(v)
                {
                    spare[0].alpha = spare[1].alpha = v;
                }});

            case ITEM:
                var itemText = new CitroText(10, 10, "USED AN ITEM ?");
                add(itemText);
                background.visible = false;
                if (enemyHealth > 0)
                {
                    enemyAttack();
                    background.visible = true;
                    remove(itemText);
                }
            case SPARE:
                var spareText = new CitroText(10, 10, "SPARED ?");
                add(spareText);
                background.visible = false;
                if (enemyHealth > 0)
                {
                    enemyAttack();
                    background.visible = true;
                    remove(spareText);
                }
                if (spareBar >= 100)
                {
                    enemyAttack();
                    outcome = SPARED;
                    results.text = "SPARED!";
                    fledSound.play();
                    results.visible = true;
                    results.alpha = 0;
                    CitroTween.tweenObject(results, {alpha: 1}, 0.66, {ease: CitroEase.CIRC_INOUT, onComplete: doneResultsIn});
                }
            case FLEE:
                if (Math.random() < 0.50)
                {
                    battle.stop();
                    vs_susie.stop();
                    outcome = ESCAPE;
                    results.text = "ESCAPED!";
                    fledSound.play();
                    results.visible = true;
                    results.alpha = 0;
                    CitroTween.tweenObject(results, {alpha: 1}, 0.66, {ease: CitroEase.CIRC_INOUT, onComplete: doneResultsIn});
                }
                else
                {
                    enemyAttack();
                    CitroTween.tweenNumber(damages[0].y, damages[0].y - 12, 1, {ease: CitroEase.CIRC_OUT, onUpdate: function(v)
                    {
                        damages[0].y = damages[1].y = v;
                    }});
                    CitroTween.tweenNumber(0, 1, 0.2, {ease: CitroEase.CIRC_INOUT, onComplete: doneDamageIn, onUpdate: function(v)
                    {
                        damages[0].alpha = damages[1].alpha = v;
                    }});
                }
        }
        wait = true;
    }

    function enemyAttack()
    {
        if (Math.random() < 0.30)
        {
            screenFlash.alpha = 1;
            CitroTween.tweenObject(screenFlash, {alpha: 0}, 0.2, {ease: CitroEase.LINEAR});

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
        damages[0].x = playerSprite.x + 2;
        damages[0].y = playerSprite.y + 4;
        damages[0].alpha = 0;
        damages[0].visible = true;
    }

    function doneDamageIn()
    {
        CitroTween.tweenNumber(1, 0, 0.66, {
            ease: CitroEase.CIRC_INOUT,
            startDelay: 1,
            onComplete: doneDamageOut,
            onUpdate: function(v)
            {
                damages[0].alpha = damages[1].alpha = v;
            }
        });
    }

    function doneSpareIn()
    {
        CitroTween.tweenNumber(1, 0, 0.66, {
            ease: CitroEase.CIRC_INOUT,
            startDelay: 1,
            onComplete: doneSpareOut,
            onUpdate: function(v)
            {
                spare[0].alpha = spare[1].alpha = v;
            }
        });
    }

    function doneResultsIn()
    {
        CitroTween.tweenObject(this, {alpha: 0}, 0.66, {ease: CitroEase.CIRC_OUT, onComplete: finishFadeOut, startDelay: 1});
    }

    function doneDamageOut()
    {
        damages[0].visible = false;
        damages[1].visible = false;
        damages[0].text = "";
        damages[1].text = "";

        if (playerHealth <= 0)
        {
            battle.stop();
            vs_susie.stop();
            outcome = DEFEAT;
            loseSound.play();
            results.text = "DEFEAT!";
            results.visible = true;
            results.alpha = 0;
            CitroTween.tweenObject(results, {alpha: 1}, 0.66, {ease: CitroEase.CIRC_INOUT, onComplete: doneResultsIn});
        }
        else if (enemyHealth <= 0)
        {
            battle.stop();
            vs_susie.stop();
            outcome = VICTORY;
            winSound.play();
            results.text = "VICTORY!";
            results.visible = true;
            results.alpha = 0;
            CitroTween.tweenObject(results, {alpha: 1}, 0.66, {ease: CitroEase.CIRC_INOUT, onComplete: doneResultsIn});
        }
        else
        {
            wait = false;
            pointer.visible = true;
        }
    }

    function doneSpareOut()
    {
        spare[0].visible = false;
        spare[1].visible = false;
        spare[0].text = "";
        spare[1].text = "";
        wait = false;
        pointer.visible = true;
    }

    function finishFadeOut()
    {
        exists = false;
        visible = false;
    }
}