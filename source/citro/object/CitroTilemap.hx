package citro.object;

import citro.CitroG;

class CitroTilemap extends CitroObject {
    public var widthInTiles:Int;
    public var heightInTiles:Int;
    public var tileSize:Int;
    public var data:Array<Array<Int>>;
    private var brush:CitroAnimate;
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
        if (!visible || alpha <= 0 || brush == null || brush.atlasSprite == null) {
            return false;
        }
        if (widthInTiles <= 0 || heightInTiles <= 0 || data.length == 0) {
            trace("[CitroTilemap] SKIP: Invalid dimensions or empty data");
            return false;
        }
        
        if (data.length > 0 && data[0].length > 0) {
            trace("[CitroTilemap] First tile: " + data[0][0] + " | Total frames: " + brush.atlasSprite.totalFrames);
        }

        var drewSomething = false;
        var tilesDrawn = 0;
        for (y in 0...Std.int(Math.min(5, heightInTiles))) {
            for (x in 0...Std.int(Math.min(5, widthInTiles))) {
                var tileIndex = data[y][x];
                
                if (tileIndex >= 0 && tileIndex < brush.atlasSprite.totalFrames) {
                    brush.atlasSprite.frame = tileIndex;
                    brush.atlasSprite.drawRaw(this.x + (x * tileSize), this.y + (y * tileSize));
                    drewSomething = true;
                    tilesDrawn++;
                } else {
                    trace("[CitroTilemap] SKIP TILE[" + x + "," + y + "]: index=" + tileIndex + " maxFrames=" + brush.atlasSprite.totalFrames);
                }
            }
        }
        
        trace("[CitroTilemap] Drew " + tilesDrawn + " tiles");
        return drewSomething;
    }
}
