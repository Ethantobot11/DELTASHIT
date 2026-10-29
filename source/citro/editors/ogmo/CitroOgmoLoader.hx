package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#else
import openfl.Assets;
#end

class CitroOgmoLoader {
    public var project:Dynamic;
    public var level:Dynamic;

    public function new(projectDataPath:String, levelDataPath:String) {
        var projectText:String = "";
        var levelText:String = "";

        #if sys
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
        #else
        projectText = Assets.getText(projectDataPath);
        levelText = Assets.getText(levelDataPath);
        #end

        if (projectText != null && projectText.length > 0) {
            try {
                project = Json.parse(projectText);
            } catch (e:Dynamic) {
                trace("ERROR parsing project JSON: " + e);
                trace("Content preview: " + projectText.substr(0, 100));
                project = {};
            }
        } else {
            trace("ERROR: Project file is empty or missing: " + projectDataPath);
            project = {};
        }

        if (levelText != null && levelText.length > 0) {
            try {
                level = Json.parse(levelText);
            } catch (e:Dynamic) {
                trace("ERROR parsing level JSON: " + e);
                trace("Content preview: " + levelText.substr(0, 100));
                level = {};
            }
        } else {
            trace("ERROR: Level file is empty or missing: " + levelDataPath);
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
        if (arrayMode == 0) {
            var data:Array<Int> = cast Reflect.field(layer, "data");
            if (data != null) {
                for (i in 0...data.length) {
                    tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = data[i];
                }
            }
        } else if (arrayMode == 1) {
            var data2D:Array<Array<Int>> = cast Reflect.field(layer, "data2D");
            if (data2D != null) {
                for (y in 0...data2D.length) {
                    for (x in 0...data2D[y].length) {
                        tilemap.data[y][x] = data2D[y][x];
                    }
                }
            }
        } else {
            var dataCSV:String = cast Reflect.field(layer, "dataCSV");
            if (dataCSV != null) {
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