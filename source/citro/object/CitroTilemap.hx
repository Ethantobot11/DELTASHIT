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
        final camX = CitroG.camera.scroll.x;
        final camY = CitroG.camera.scroll.y;
        final screenWidth = bottom ? 320 : 400;
        final screenHeight = 240;
        final startCol = Math.max(0, Math.floor((camX - x) / tileSize));
        final endCol = Math.min(widthInTiles, Math.ceil((camX + screenWidth - x) / tileSize));
        final startRow = Math.max(0, Math.floor((camY - y) / tileSize));
        final endRow = Math.min(heightInTiles, Math.ceil((camY + screenHeight - y) / tileSize));
        var drewSomething = false;
        for (row in startRow...endRow) {
            for (col in startCol...endCol) {
                var tileIndex = data[row][col];
                if (tileIndex > 0 && tileIndex < brush.atlasSprite.totalFrames) {
                    brush.atlasSprite.frame = tileIndex;
                    brush.atlasSprite.x = this.x + (col * tileSize);
                    brush.atlasSprite.y = this.y + (row * tileSize);
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