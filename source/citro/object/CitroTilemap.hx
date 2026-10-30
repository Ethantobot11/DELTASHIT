package citro.object;

import citro.CitroG;

class CitroTilemap extends CitroObject {
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var tileSize:Int;
    public var data:Array<Array<Int>>;
    private var brush:CitroAnimate;
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
        brush = new CitroAnimate();
        trace("[CitroTilemap] Created: " + widthInTiles + "x" + heightInTiles + " tiles, size: " + tileSize);
    }

    public function loadGraphic(tileGraphicPath:String):Bool {
        trace("[CitroTilemap] Loading graphic: " + tileGraphicPath);
        var anims = new Map<String, Array<Int>>();
        brush.loadFromT3XWithAnims(tileGraphicPath, tileSize, tileSize, anims);
        if (brush.atlasSprite == null || brush.atlasSprite.totalFrames == 0) {
            trace("[CitroTilemap] ERROR: Failed to load tileset!");
            return false;
        }
        trace("[CitroTilemap] Graphic loaded. Total frames: " + brush.atlasSprite.totalFrames);
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
        if (!visible || alpha <= 0 || brush == null || brush.atlasSprite == null) {
            return false;
        }        
        final screenWidth = this.bottom ? CitroG.BOTTOM_WIDTH : CitroG.WIDTH;
        final screenHeight = CitroG.HEIGHT;
        final startX = Math.max(0, Math.floor((0 - this.x) / tileSize));
        final endX = Math.min(widthInTiles, Math.ceil((screenWidth - this.x) / tileSize));
        final startY = Math.max(0, Math.floor((0 - this.y) / tileSize));
        final endY = Math.min(heightInTiles, Math.ceil((screenHeight - this.y) / tileSize));
        final intStartX = Std.int(startX);
        final intEndX = Std.int(endX);
        final intStartY = Std.int(startY);
        final intEndY = Std.int(endY);
        var drewSomething = false;
        for (y in intStartY...intEndY) {
            if (y < 0 || y >= data.length) continue;
            var row = data[y];
            
            for (x in intStartX...intEndX) {
                if (x < 0 || x >= row.length) continue;
                
                var tileIndex = row[x];
                if (tileIndex >= 0 && tileIndex < brush.atlasSprite.totalFrames) {
                    brush.atlasSprite.frame = tileIndex;
                    brush.atlasSprite.x = this.x + (x * tileSize);
                    brush.atlasSprite.y = this.y + (y * tileSize);
                    brush.atlasSprite.alpha = this.alpha;
                    brush.atlasSprite.scale.x = this.scale.x;
                    brush.atlasSprite.scale.y = this.scale.y;
                    brush.atlasSprite.bottom = this.bottom;
                    brush.atlasSprite.update();
                    drewSomething = true;
                }
            }
        }
        return drewSomething;
    }
}