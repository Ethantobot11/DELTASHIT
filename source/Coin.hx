package;

import citro.object.CitroSprite;
import citro.backend.CitroTween;
import citro.backend.CitroTween.CitroEase;

class Coin extends CitroSprite {
    public function new(x:Float, y:Float) {
        super(x, y);
        loadGraphic("romfs:/assets/images/coin.t3x");
        setSourceRect(0, 0, 16, 16);
    }

    public function kill() {
        exists = false;
        CitroTween.tweenObject(this, {alpha: 0, y: y - 16}, 0.33, {
            ease: CitroEase.CIRC_OUT, 
            onComplete: finishKill
        });
    }

    function finishKill() {
        exists = false;
    }
}