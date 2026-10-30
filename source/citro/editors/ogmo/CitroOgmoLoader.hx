package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

class CitroOgmoLoader {
    public var project:Dynamic;
    public var level:Dynamic;
        public function new(projectDataPath:String, levelDataPath:String) {
        var projectText = "";
        var levelText = "";
        #if sys
        try {
            if (FileSystem.exists(projectDataPath)) {
                projectText = File.getContent(projectDataPath);
            } else {
                trace("Warning: Project file does not exist at: " + projectDataPath);
            }
            
            if (FileSystem.exists(levelDataPath)) {
                levelText = File.getContent(levelDataPath);
            } else {
                trace("Warning: Level file does not exist at: " + levelDataPath);
            }
        } catch (e:Dynamic) {
            trace("Error loading Ogmo files: " + e);
        }
        #end
        if (projectText != null && projectText.length > 0) {
            try {
                project = Json.parse(projectText);
            } catch (e:Dynamic) {
                trace("ERROR parsing project JSON: " + e);
                project = {};
            }
        } else {
            trace("Error: Project file is empty or missing: " + projectDataPath);
            project = {};
        }

        if (levelText != null && levelText.length > 0) {
            try {
                level = Json.parse(levelText);
            } catch (e:Dynamic) {
                trace("ERROR parsing level JSON: " + e);
                var lines = levelText.split("\n");
                var charCount = 0;
                for (i in 0...lines.length) {
                    charCount += lines[i].length + 1;
                    if (charCount >= 4000) {
                        trace("The error is around line " + (i + 1) + ": " + lines[i]);
                        break;
                    }
                }
                level = {};
            }
        } else {
            trace("Error: Level file is empty or missing: " + levelDataPath);
            level = {};
        }
    }

    public function loadTilemap(tileGraphic:String, tileLayer:String = "tiles", tileSize:Int = 16):CitroTilemap {
        var tilemap = new CitroTilemap(0, 0, tileSize);
        var layer = getTileLayer(level, tileLayer);
        if (layer == null) {
            trace("Warning: Tile layer '" + tileLayer + "' not found in level data.");
            return tilemap;
        }
        
        tilemap.widthInTiles = Std.int(Reflect.field(layer, "gridCellsX"));
        tilemap.heightInTiles = Std.int(Reflect.field(layer, "gridCellsY"));
        tilemap.tileSize = tileSize;
        tilemap.data = [];
        
        for (y in 0...tilemap.heightInTiles) {
            var row = [];
            for (x in 0...tilemap.widthInTiles) row.push(0);
            tilemap.data.push(row);
        }

        var arrayMode:Int = Std.int(Reflect.field(layer, "arrayMode"));
        if (arrayMode == 0 && layer.data != null) {
            var data:Array<Int> = cast Reflect.field(layer, "data");
            for (i in 0...data.length) {
                tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = data[i];
            }
        } else if (arrayMode == 1 && layer.data2D != null) {
            var data2D:Array<Array<Int>> = cast Reflect.field(layer, "data2D");
            for (y in 0...data2D.length) {
                for (x in 0...data2D[y].length) {
                    tilemap.data[y][x] = data2D[y][x];
                }
            }
        } else if (layer.dataCSV != null) {
            var dataCSV:String = cast Reflect.field(layer, "dataCSV");
            tilemap.loadMapFromCSV(dataCSV, tileSize);
        }
        
        return tilemap;
    }

    public function loadEntities(entityLoadCallback:Dynamic->Void, entityLayer:String = "entities"):Void {
        var layer = getEntityLayer(level, entityLayer);
        if (layer != null) {
            var entities:Array<Dynamic> = cast Reflect.field(layer, "entities");
            if (entities != null) {
                for (entity in entities) {
                    entityLoadCallback(entity);
                }
            } else {
                trace("Warning: Entity layer '" + entityLayer + "' has no entities.");
            }
        } else {
            trace("Warning: Entity layer '" + entityLayer + "' not found.");
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = cast Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(Reflect.field(layer, "name"));
                if (layerName != null && layerName.trim() == name) {
                    return layer;
                }
            }
        }
        return null;
    }

    static function getEntityLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = cast Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(Reflect.field(layer, "name"));
                if (layerName != null && layerName.trim() == name) {
                    return layer;
                }
            }
        }
        return null;
    }
}