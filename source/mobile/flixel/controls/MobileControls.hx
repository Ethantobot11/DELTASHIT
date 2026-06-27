package mobile.flixel.controls;

#if flixel
class MobileControls extends FlxSpriteGroup {
    private var controls:Array<InputHandler> = [];

    public var buttons:Array<Button> = [];
    public var dpads:Array<DPad> = [];
    public var joysticks:Array<Joystick> = [];
    public var hitboxes:Array<Hitbox> = [];

    public function new() {
        super();
    }

    public function getHitboxFromName(name:String) {
        for (btn in hitboxes) {
            if (btn != null && btn.jsonName == name) return btn;
        }
        return null;
    }

    public function getDPadFromName(name:String) {
        for (btn in dpads) {
            if (btn != null && btn.jsonName == name) return btn;
        }
        return null;
    }

    public function getJoyStickFromName(name:String) {
        for (btn in joysticks) {
            if (btn != null && btn.jsonName == name) return btn;
        }
        return null;
    }

    public function getButtonFromName(name:String) {
        for (btn in buttons) {
            if (btn != null && btn.jsonName == name) return btn;
        }
        return null;
    }

    public function addButtonCamera() {
        var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false); 
        for (btn in buttons) {
            btn.cameras = [cam];
        }
    }

    public function addDPadCamera() {
        var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false); 
        for (btn in dpads) {
            btn.cameras = [cam];
        }
    }

    public function addJoyStickCamera() {
        var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false); 
        for (btn in joysticks) {
            btn.cameras = [cam];
        }
    }

    public function addHitboxCamera() {
        var cam:FlxCamera = new FlxCamera();
		cam.bgColor.alpha = 0;
		FlxG.cameras.add(cam, false); 
        for (btn in hitboxes) {
            btn.cameras = [cam];
        }
    }

    public function addButton(name:String) {
        if (buttons.length > 0) removeButton();
        var rawContent = File.getContent(Config.BUTTON_JSON + name + ".json");
        if (rawContent == null) return;
        var parsed:Dynamic = Json.parse(rawContent);
        for (data in (parsed.buttons : Array<Dynamic>)) {
            var btn = new Button(data);
            addControl(btn);
            buttons.push(btn);
        }
    }

    public function addDPad(name:String) {
        if (dpads.length > 0) removeDPad();
        var rawContent = File.getContent(Config.DPAD_JSON + name + ".json");
        if (rawContent == null) return;
        var parsed:Dynamic = Json.parse(rawContent);
        for (data in (parsed.dpads : Array<Dynamic>)) {
            var dpad = new DPad(data);
            addControl(dpad);
            dpads.push(dpad);
        }
    }

    public function addJoyStick(name:String) {
        if (joysticks.length > 0) removeJoyStick();
        var rawContent = File.getContent(Config.JOYSTICK_JSON + name + ".json");
        if (rawContent == null) return;
        var parsed:Dynamic = Json.parse(rawContent);
        for (data in (parsed.joysticks : Array<Dynamic>)) {
            var joy = new Joystick(data);
            addControl(joy);
            joysticks.push(joy);
        }
    }

    public function addHitbox(name:String) {
        if (hitboxes.length > 0) removeHitbox();
        var rawContent = File.getContent(Config.HITBOX_JSON + name + ".json");
        if (rawContent == null) return;
        var parsed:Dynamic = Json.parse(rawContent);
        for (data in (parsed.hitboxes : Array<Dynamic>)) {
            var box = new Hitbox(data);
            addControl(box);
            hitboxes.push(box);
        }
    }

    private function addControl(c:InputHandler) {
        controls.push(c);
        add(c);
    }

    public function removeButton() {
        for (btn in buttons) { controls.remove(btn); remove(btn, true); }
        buttons = [];
    }

    public function removeDPad() {
        for (dpad in dpads) { controls.remove(dpad); remove(dpad, true); }
        dpads = [];
    }

    public function removeJoyStick() {
        for (joy in joysticks) { controls.remove(joy); remove(joy, true); }
        joysticks = [];
    }

    public function removeHitbox() {
        for (box in hitboxes) { controls.remove(box); remove(box, true); }
        hitboxes = [];
    }

    public function clearControls() {
        removeButton();
        removeDPad();
        removeJoyStick();
        removeHitbox();
        resetAllInputs();
    }

    public function checkState(id:String, state:String = "pressed"):Bool {
        for (c in controls) {
            if (c == null || c.disabled) continue;
            switch (state.toLowerCase()) {
                case "pressed": if (c.pressed(id)) return true;
                case "justpressed": if (c.justPressed(id)) return true;
                case "justreleased": if (c.justReleased(id)) return true;
                case "released": if (c.released(id)) return true;
            }
        }
        return false;
    }

    public function resetAllInputs() {
        for (c in controls) {
            if (c != null) c.resetInputs();
        }
    }
}
#end