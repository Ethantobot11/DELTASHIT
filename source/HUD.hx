package;

import citro.object.CitroGroup;
import citro.object.CitroSprite;
import citro.object.CitroText;
import citro.CitroG;

class HUD extends CitroGroup {
    var background:CitroSprite;
    var healthCounter:CitroText;
    var moneyCounter:CitroText;
    var healthIcon:CitroSprite;
    var moneyIcon:CitroSprite;

    public function new() {
        super();
        background = new CitroSprite(0, 0);
        background.makeGraphic(400, 20, 0xFF000000);
        
        healthCounter = new CitroText(16, 2, "20 / 20");
        healthCounter.setBorderStyle(0xFF808080, 1, SHADOW);
        
        moneyCounter = new CitroText(0, 2, "0");
        moneyCounter.setBorderStyle(0xFF808080, 1, SHADOW);
        moneyCounter.alignment = RIGHT;
        
        healthIcon = new CitroSprite(4, healthCounter.y);
        healthIcon.loadGraphic("romfs:/assets/images/health.t3x");
        
        moneyIcon = new CitroSprite(400 - 12, moneyCounter.y);
        moneyIcon.loadGraphic("romfs:/assets/images/coin.t3x");
        moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
        
        add(background);
        add(healthIcon);
        add(moneyIcon);
        add(healthCounter);
        add(moneyCounter);
    }

    public function updateHUD(health:Int, money:Int) {
        healthCounter.text = health + " / 20";
        moneyCounter.text = Std.string(money);
        moneyCounter.x = moneyIcon.x - moneyCounter.width - 4;
    }
}