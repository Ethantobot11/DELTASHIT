package mobile.openfl.controls;

class Button extends InputHandler {
    public var controlID:String;

    public function new(data:Dynamic) {
        super(data.position != null ? data.position[0] : 0, data.position != null ? data.position[1] : 0, false);
        jsonName = data.name;
        controlID = data.id;
        loadElementGraphics(data.graphic, data.subgraphic, data.spritesheet, Config.BUTTON_PATH, data.color, data.scale != null ? data.scale : 1.0);
    }

    override public function updateInputs() {
        if (disabled) return;
        super.updateInputs();

        var isHit = false;
        if (checkOverlap(this)) {
            isHit = true;
        }

        if (isHit) activeIDs.push(controlID);
        applyBrightness(activeIDs.length > 0);
    }
}