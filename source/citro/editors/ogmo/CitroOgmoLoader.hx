package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

class CitroOgmoLoader {
    var project:Dynamic;
    var level:Dynamic;

    public function new(projectDataPath:String, levelDataPath:String) {
        var projectText = "";
        var levelText = "";
        
        #if sys
        try {
            if (FileSystem.exists(projectDataPath)) {
                projectText = File.getContent(projectDataPath);
            } else {
                trace("[OgmoLoader] Warning: Project file does not exist at: " + projectDataPath);
            }
            
            if (FileSystem.exists(levelDataPath)) {
                levelText = File.getContent(levelDataPath);
            } else {
                trace("[OgmoLoader] Warning: Level file does not exist at: " + levelDataPath);
            }
        } catch (e:Dynamic) {
            trace("[OgmoLoader] Error loading Ogmo files: " + e);
        }
        #end
        
        if (projectText != null && projectText.length > 0) {
            try {
                project = Json.parse(projectText);
            } catch (e:Dynamic) {
                trace("[OgmoLoader] Error parsing project JSON: " + e);
                project = {};
            }
        } else {
            project = {};
        }
        
        if (levelText != null && levelText.length > 0) {
            try {
                level = Json.parse(levelText);
            } catch (e:Dynamic) {
                trace("[OgmoLoader] Error parsing level JSON: " + e);
                level = {};
            }
        } else {
            level = {};
        }
    }

    public function loadTilemap(tileGraphic:String, tileLayer:String = "tiles", tileSize:Int = 16):CitroTilemap {
        var layer = getTileLayer(level, tileLayer);
        if (layer == null) {
            trace("[OgmoLoader] Warning: Tile layer '" + tileLayer + "' not found in level data. Available layers:");
            if (level != null && Reflect.hasField(level, "layers")) {
                var layers:Array<Dynamic> = cast Reflect.field(level, "layers");
                for (l in layers) {
                    trace(" - " + Reflect.field(l, "name"));
                }
            }
            return new CitroTilemap(0, 0, tileSize);
        }
        
        var arrayMode:Int = Std.int(Reflect.field(layer, "arrayMode"));
        var gridCellsX:Int = Std.int(Reflect.field(layer, "gridCellsX"));
        var gridCellsY:Int = Std.int(Reflect.field(layer, "gridCellsY"));
        
        trace("[OgmoLoader] Found tile layer: '" + tileLayer + "'. ArrayMode: " + arrayMode);
        
        var tilemap = new CitroTilemap(gridCellsX, gridCellsY, tileSize);
        tilemap.loadGraphic(tileGraphic);
        
        if (arrayMode == 0) {
            var data:Array<Int> = cast Reflect.field(layer, "data");
            if (data != null) {
                trace("[OgmoLoader] Loading 1D array data, length: " + data.length);
                for (i in 0...data.length) {
                    var tileIndex = data[i];
                    if (tileIndex < 0) tileIndex = 0;
                    tilemap.data[Math.floor(i / gridCellsX)][i % gridCellsX] = tileIndex;
                }
            }
        } else if (arrayMode == 1) {
            var data2D:Array<Array<Int>> = cast Reflect.field(layer, "data2D");
            if (data2D != null) {
                trace("[OgmoLoader] Loading 2D array data");
                for (y in 0...data2D.length) {
                    for (x in 0...data2D[y].length) {
                        var tileIndex = data2D[y][x];
                        if (tileIndex < 0) tileIndex = 0;
                        tilemap.data[y][x] = tileIndex;
                    }
                }
            }
        } else {
            var dataCSV:String = cast Reflect.field(layer, "dataCSV");
            if (dataCSV != null) {
                trace("[OgmoLoader] Loading CSV data");
                tilemap.loadMapFromCSV(dataCSV, tileSize);
            }
        }
        
        return tilemap;
    }

    public function loadEntities(entityLoadCallback:Dynamic->Void, entityLayer:String = "entities"):Void {
        var layer = getEntityLayer(level, entityLayer);
        if (layer != null) {
            var entities:Array<Dynamic> = cast Reflect.field(layer, "entities");
            if (entities != null) {
                trace("[OgmoLoader] Found entity layer: '" + entityLayer + "'. Entities count: " + entities.length);
                for (entity in entities) {
                    entityLoadCallback(entity);
                }
            } else {
                trace("[OgmoLoader] Warning: Entity layer '" + entityLayer + "' has no entities.");
            }
        } else {
            trace("[OgmoLoader] Warning: Entity layer '" + entityLayer + "' not found.");
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = cast Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                if (Reflect.field(layer, "name") == name) {
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
                if (Reflect.field(layer, "name") == name) {
                    return layer;
                }
            }
        }
        return null;
    }
}