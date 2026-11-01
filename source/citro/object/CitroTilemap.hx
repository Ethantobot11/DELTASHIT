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
        trace("[CitroTilemap] Created: " + widthInTiles + "x" + heightInTiles + " tiles, size: " + tileSize);
    }

    public function loadGraphic(tileGraphicPath:String):Bool {
        trace("[CitroTilemap] Loading: " + tileGraphicPath);
        if (!brush.loadGraphic(tileGraphicPath, tileSize, tileSize)) {
            trace("[CitroTilemap] FAILED TO LOAD T3X!");
            return false;
        }
        trace("[CitroTilemap] SUCCESS! Sheet size: " + brush.sheetWidth + "x" + brush.sheetHeight);
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
        var localX = x - this.x;
        var localY = y - this.y;
        
        var left = Math.floor(localX / tileSize);
        var right = Math.floor((localX + width - 0.1) / tileSize);
        var top = Math.floor(localY / tileSize);
        var bottom = Math.floor((localY + height - 0.1) / tileSize);
        
        for (ty in top...bottom + 1) {
            for (tx in left...right + 1) {
                if (ty >= 0 && ty < heightInTiles && tx >= 0 && tx < widthInTiles) {
                    var tile = data[ty][tx];
                    if (tile > 0) {
                        return true;
                    }
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
        if (!visible || alpha <= 0 || brush == null) {
            return false;
        }

        if (widthInTiles <= 0 || heightInTiles <= 0 || data.length == 0) {
            return false;
        }

        var framesPerRow:Int = Std.int(brush.sheetWidth / tileSize);
        var maxTiles:Int = framesPerRow * Std.int(brush.sheetHeight / tileSize);
        var screenWidth = this.bottom ? CitroG.BOTTOM_WIDTH : CitroG.WIDTH;
        var screenHeight = CitroG.HEIGHT;
        var startTileX = Std.int(Math.max(0, Math.floor((-this.x) / tileSize) - 1));
        var endTileX = Std.int(Math.min(widthInTiles, Math.ceil((screenWidth - this.x) / tileSize) + 1));
        var startTileY = Std.int(Math.max(0, Math.floor((-this.y) / tileSize) - 1));
        var endTileY = Std.int(Math.min(heightInTiles, Math.ceil((screenHeight - this.y) / tileSize) + 1));
        var tilesDrawn = 0;
        brush.alpha = this.alpha;
        brush.scale.x = this.scale.x;
        brush.scale.y = this.scale.y;
        brush.color = this.color;
        for (y in startTileY...endTileY) {
            if (y >= data.length) break;
            var row = data[y];
            if (row == null) continue;
            for (x in startTileX...endTileX) {
                if (x >= row.length) break;
                var tileIndex = row[x];
                if (skipEmptyIndex && tileIndex == 0) {
                    continue;
                }
                
                if (tileIndex < 0 || tileIndex >= maxTiles) {
                    continue;
                }
                
                var srcX:Float = (tileIndex % framesPerRow) * tileSize;
                var srcY:Float = Math.floor(tileIndex / framesPerRow) * tileSize;
                brush.setSourceRect(srcX, srcY, tileSize, tileSize);
                var drawX = this.x + (x * tileSize);
                var drawY = this.y + (y * tileSize);
                brush.drawRaw(drawX, drawY);
                tilesDrawn++;
            }
        }
        
        return tilesDrawn > 0;
    }
}
