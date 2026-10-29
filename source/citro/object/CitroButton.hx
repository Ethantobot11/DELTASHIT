package citro.object;

import citro.CitroG;
import citro.backend.CitroColor;
import haxe3ds.services.HID;

class CitroButton extends CitroSprite 
{
    public var label:CitroText;
    public var onClicked:Void->Void;
    
    private var isHovered:Bool = false;
    private var baseColor:CitroColor;
    private var hoverColor:CitroColor;

    public function new(X:Float, Y:Float, Width:Float, Height:Float, LabelText:String, ?OnClick:Void->Void) 
    {
        super(X, Y);
        makeGraphic(Width, Height, 0xFF444444);
        baseColor = 0xFF444444;
        hoverColor = 0xFFFFD700;
        
        label = new CitroText(X + (Width / 2), Y + (Height / 2), LabelText);
        label.alignment = Center;
        
        onClicked = OnClick;
    }

    override public function update():Bool 
    {
        if (isHovered && HID.keyPressed(HIDKey.A || HIDKey.TOUCH)) {
            if (onClicked != null) onClicked();
        }
        return super.update();
    }

    public function setHovered(Hovered:Bool):Void 
    {
        isHovered = Hovered;
        color = isHovered ? hoverColor : baseColor;
    }
}
