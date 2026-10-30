package citro.object;

import citro.CitroG;

class CitroTilemap extends CitroObject {
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var tileSize:Int;
    public var data:Array<Array<Int>>;
    private var brush:CitroSprite;

    public function new(WidthInTiles:Int, HeightInTiles:Int, TileSize:Int) {
        super();
        widthInTiles = WidthInTiles;
        heightInTiles = HeightInTiles;
        tileSize = TileSize;
        data = [];
        
        for (y in 0...heightInTiles) {
            var row = [];
            for (x in 0...widthInTiles) {
                row.push(0);
            }
            data.push(row);
        }
        
        brush = new CitroSprite();
        trace("[CitroTilemap] Created: " + widthInTiles + "x" + heightInTiles + " tiles, size: " + tileSize);
    }

    public function loadGraphic(tileGraphicPath:String):Void {
        trace("[CitroTilemap] Loading graphic: " + tileGraphicPath);
        brush.loadGraphic(tileGraphicPath, tileSize, tileSize);
        trace("[CitroTilemap] Graphic loaded. Total frames available: " + brush.totalFrames);
    }

    public function setTile(X:Int, Y:Int, TileIndex:Int):Void {
        if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles) {
            data[Y][X] = TileIndex;
        }
    }

    public function getTile(X:Int, Y:Int):Int {
        if (X >= 0 && X < widthInTiles && Y >= 0 && Y < heightInTiles) {
            return data[Y][X];
        }
        return 0;
    }

    public function loadMapFromCSV(MapData:String, TileSize:Int):Void {
        tileSize = TileSize;
        var rows = MapData.split("\n");
        heightInTiles = rows.length;
        
        if (heightInTiles > 0) {
            widthInTiles = rows[0].split(",").length;
            data = [];
            
            for (y in 0...heightInTiles) {
                var cols = rows[y].split(",");
                var row = [];
                for (x in 0...widthInTiles) {
                    var val = Std.parseInt(cols[x]);
                    row.push(val != null ? val : 0);
                }
                data.push(row);
            }
        }
    }

    override public function update():Bool {
        if (!visible || alpha <= 0 || brush == null || brush.totalFrames == 0) {
            return false;
        }
        
        for (y in 0...heightInTiles) {
            for (x in 0...widthInTiles) {
                var tileIndex = data[y][x];
                if (tileIndex >= 0 && tileIndex < brush.totalFrames) {
                    brush.frame = tileIndex;
                    brush.x = this.x + (x * tileSize);
                    brush.y = this.y + (y * tileSize);
                    brush.alpha = this.alpha;
                    brush.scale.x = this.scale.x;
                    brush.scale.y = this.scale.y;
                    brush.bottom = this.bottom;
                    brush.update();
                }
            }
        }
        return true;
    }
}