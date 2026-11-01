package citro.object;

import citro.CitroG;

class CitroTilemap extends CitroObject {
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var tileSize:Int;
    public var data:Array<Array<Int>>;
    private var brush:CitroSprite;
    public var skipEmptyIndex:Bool = true;
    
    public function new(WidthInTiles:Int, HeightInTiles:Int, TileSize:Int) {
        super();
        widthInTiles = WidthInTiles;
        heightInTiles = HeightInTiles;
        tileSize = TileSize;
        this.width = widthInTiles * tileSize;
        this.height = heightInTiles * tileSize;
        
        data = [];
        for (y in 0...heightInTiles) {
            var row = [];
            for (x in 0...widthInTiles) {
                row.push(0);
            }
            data.push(row);
        }
        brush = new CitroSprite();
    }

    public function loadGraphic(tileGraphicPath:String):Bool {
        if (!brush.loadGraphic(tileGraphicPath, tileSize, tileSize)) {
            trace("[CitroTilemap] FAILED TO LOAD T3X!");
            return false;
        }
        return true;
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

    public function checkTileCollision(x:Float, y:Float, width:Float, height:Float):Bool {
        var w = width > 0 ? width : tileSize;
        var h = height > 0 ? height : tileSize;
        var localX = x - this.x;
        var localY = y - this.y;
        var left = Std.int(localX / tileSize);
        var right = Std.int((localX + w - 0.1) / tileSize);
        var top = Std.int(localY / tileSize);
        var bottom = Std.int((localY + h - 0.1) / tileSize);
        if (left > right) { var temp = left; left = right; right = temp; }
        if (top > bottom) { var temp = top; top = bottom; bottom = temp; }
        
        for (ty in top...bottom + 1) {
            for (tx in left...right + 1) {
                if (ty >= 0 && ty < heightInTiles && tx >= 0 && tx < widthInTiles) {
                    if (data[ty][tx] > 0) return true;
                }
            }
        }
        return false;
    }

    public function loadMapFromCSV(MapData:String, TileSize:Int):Void {
        tileSize = TileSize;
        var rows = MapData.split("\n");
        heightInTiles = rows.length;
        if (heightInTiles > 0) {
            widthInTiles = rows[0].split(",").length;
            data = [];
            this.width = widthInTiles * tileSize;
            this.height = heightInTiles * tileSize;
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
        if (!visible || alpha <= 0 || brush == null) return false;
        if (widthInTiles <= 0 || heightInTiles <= 0 || data.length == 0) return false;
        var framesPerRow:Int = Std.int(brush.sheetWidth / tileSize);
        var maxTiles:Int = framesPerRow * Std.int(brush.sheetHeight / tileSize);
        brush.alpha = this.alpha;
        brush.scale.x = this.scale.x;
        brush.scale.y = this.scale.y;
        brush.color = this.color;
        for (y in 0...heightInTiles) {
            var row = data[y];
            if (row == null) continue;
            for (x in 0...widthInTiles) {
                var tileIndex = row[x];
                if (skipEmptyIndex && tileIndex == 0) continue;
                if (tileIndex < 0 || tileIndex >= maxTiles) continue;
                var srcX:Float = (tileIndex % framesPerRow) * tileSize;
                var srcY:Float = Math.floor(tileIndex / framesPerRow) * tileSize;
                brush.setSourceRect(srcX, srcY, tileSize, tileSize);
                brush.drawRaw(this.x + (x * tileSize), this.y + (y * tileSize));
            }
        }
        return true;
    }
}
