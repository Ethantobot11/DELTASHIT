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
                trace("Error parsing project JSON: " + e + " | Content preview: " + projectText.substr(0, 50));
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
                trace("Error parsing level JSON: " + e + " | Content preview: " + levelText.substr(0, 50));
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
        if (layer == null) return tilemap;

        tilemap.widthInTiles = layer.gridCellsX;
        tilemap.heightInTiles = layer.gridCellsY;
        tilemap.tileSize = tileSize;
        tilemap.data = [];

        for (y in 0...tilemap.heightInTiles) {
            var row = [];
            for (x in 0...tilemap.widthInTiles) row.push(0);
            tilemap.data.push(row);
        }

        if (layer.arrayMode == 0 && layer.data != null) {
            for (i in 0...layer.data.length) {
                tilemap.data[Math.floor(i / layer.gridCellsX)][i % layer.gridCellsX] = layer.data[i];
            }
        } else if (layer.arrayMode == 1 && layer.data2D != null) {
            for (y in 0...layer.data2D.length) {
                for (x in 0...layer.data2D[y].length) {
                    tilemap.data[y][x] = layer.data2D[y][x];
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
            for (entity in entities) entityLoadCallback(entity);
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) 
                if (Reflect.field(layer, "name") == name) 
                    return layer;
        }
        return null;
    }

    static function getEntityLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) 
                if (Reflect.field(layer, "name") == name) 
                    return layer;
        }
        return null;
    }
}