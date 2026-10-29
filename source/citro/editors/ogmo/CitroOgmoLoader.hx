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
                trace("Error parsing project JSON: " + e);
                project = {};
            }
        } else {
            project = {};
        }
        
        if (levelText != null && levelText.length > 0) {
            try {
                level = Json.parse(levelText);
            } catch (e:Dynamic) {
                trace("Error parsing level JSON: " + e);
                level = {};
            }
        } else {
            level = {};
        }
    }

    public function loadTilemap(tileGraphic:String, tileLayer:String = "tiles", tileSize:Int = 16):CitroTilemap {
        var layer = getTileLayer(level, tileLayer);
        if (layer == null) {
            trace("Warning: Tile layer '" + tileLayer + "' not found in level data.");
            return new CitroTilemap(0, 0, tileSize);
        }
        
        var tilemap = new CitroTilemap(layer.gridCellsX, layer.gridCellsY, tileSize);
        tilemap.loadGraphic(tileGraphic);
        
        if (layer.arrayMode == 0 && layer.data != null) {
            for (i in 0...layer.data.length) {
                var tileIndex = layer.data[i];
                if (tileIndex < 0) tileIndex = 0;
                tilemap.data[Math.floor(i / layer.gridCellsX)][i % layer.gridCellsX] = tileIndex;
            }
        } else if (layer.arrayMode == 1 && layer.data2D != null) {
            for (y in 0...layer.data2D.length) {
                for (x in 0...layer.data2D[y].length) {
                    var tileIndex = layer.data2D[y][x];
                    if (tileIndex < 0) tileIndex = 0;
                    tilemap.data[y][x] = tileIndex;
                }
            }
        } else if (layer.dataCSV != null) {
            tilemap.loadMapFromCSV(layer.dataCSV, tileSize);
        }
        
        return tilemap;
    }

    public function loadEntities(entityLoadCallback:Dynamic->Void, entityLayer:String = "entities"):Void {
        var layer = getEntityLayer(level, entityLayer);
        if (layer != null && layer.entities != null) {
            var entities:Array<Dynamic> = layer.entities;
            for (entity in entities) {
                entityLoadCallback(entity);
            }
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = Reflect.field(data, "layers");
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
        var layers:Array<Dynamic> = Reflect.field(data, "layers");
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