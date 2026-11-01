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
        trace("[CitroTilemap] SUCCESS! Total frames: " + brush.totalFrames);
        trace("[CitroTilemap] Sheet size: " + brush.sheetWidth + "x" + brush.sheetHeight);
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
        trace("[CitroTilemap] update() START");
        
        if (!visible || alpha <= 0) {
            trace("[CitroTilemap] SKIP: not visible or alpha <= 0");
            return false;
        }
        if (brush == null) {
            trace("[CitroTilemap] SKIP: brush is NULL!");
            return false;
        }
        if (data == null) {
            trace("[CitroTilemap] SKIP: data is NULL!");
            return false;
        }

        if (widthInTiles <= 0 || heightInTiles <= 0 || data.length == 0) {
            trace("[CitroTilemap] SKIP: invalid dimensions");
            return false;
        }

        var maxFrame = brush.totalFrames;
        trace("[CitroTilemap] maxFrame = " + maxFrame);
        
        if (this.scale == null) {
            trace("[CitroTilemap] ERROR: this.scale is NULL! Fixing...");
            this.scale = new CitroVector2D();
        }
        
        trace("[CitroTilemap] About to start loop. heightInTiles=" + heightInTiles);
        
        var tilesDrawn = 0;
        
        for (y in 0...heightInTiles) {
            trace("[CitroTilemap] Loop y=" + y);
            if (y >= data.length) {
                trace("[CitroTilemap] Breaking: y >= data.length");
                break;
            }
            var row = data[y];
            if (row == null) {
                trace("[CitroTilemap] ERROR: row is NULL at y=" + y);
                continue;
            }
            
            for (x in 0...widthInTiles) {
                if (x >= row.length) break;
                
                var tileIndex = row[x];
                
                if (skipEmptyIndex && tileIndex == 0) {
                    continue;
                }
                
                if (tileIndex < 0 || tileIndex >= maxFrame) {
                    trace("[CitroTilemap] Invalid tile at (" + x + "," + y + "): index=" + tileIndex);
                    continue;
                }
                
                trace("[CitroTilemap] Setting properties for tile " + tileIndex);
                // brush.frame = tileIndex; 
                brush.alpha = this.alpha;
                if (brush.scale == null) {
                    trace("[CitroTilemap] ERROR: brush.scale is NULL!");
                } else {
                    brush.scale.x = this.scale.x;
                    brush.scale.y = this.scale.y;
                }
                
                brush.color = this.color;
                
                var drawX = this.x + (x * tileSize);
                var drawY = this.y + (y * tileSize);
                
                trace("[CitroTilemap] Calling drawRaw at " + drawX + "," + drawY);
                brush.drawRaw(drawX, drawY);
                trace("[CitroTilemap] drawRaw finished");
                
                tilesDrawn++;
                if (tilesDrawn >= 10) {
                    trace("[CitroTilemap] Drew 10 tiles, stopping loop to prevent spam.");
                    return true; 
                }
            }
        }
        
        trace("[CitroTilemap] update() END. Drew " + tilesDrawn + " tiles");
        return tilesDrawn > 0;
    }
}
