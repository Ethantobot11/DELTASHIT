package citro.object;

import citro.CitroG;
import citro.object.CitroSprite;

class CitroTilemap extends CitroObject
{
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var tileSize:Int;
    public var data:Array<Array<Int>>;

    public var tileGraphics:Map<Int, CitroSprite>;

    public function new(WidthInTiles:Int, HeightInTiles:Int, TileSize:Int) 
    {
        super();
        widthInTiles = WidthInTiles;
        heightInTiles = HeightInTiles;
        tileSize = TileSize;
        data = [];
        tileGraphics = new Map();

        for (y in 0...heightInTiles) {
            var row = [];
            for (x in 0...widthInTiles) {
                row.push(0);
            }
            data.push(row);
        }
    }

    public function setTile(X:Int, Y:Int, TileIndex:Int):Void 
    {
        if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles) {
            data[Y][X] = TileIndex;
        }
    }

    public function getTile(X:Int, Y:Int):Int 
    {
        if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles) {
            return data[Y][X];
        }
        return 0;
    }

    public function loadMapFromCSV(MapData:String, TileSize:Int):Void 
    {
        tileSize = TileSize;
        var rows = MapData.split("\n");
        heightInTiles = rows.length;
        widthInTiles = rows[0].split(",").length;
        data = [];

        for (y in 0...heightInTiles) {
            var cols = rows[y].split(",");
            var row = [];
            for (x in 0...widthInTiles) {
                row.push(Std.parseInt(cols[x]));
            }
            data.push(row);
        }
    }

    override public function update():Bool 
    {
        return super.update();
    }
}
