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
            if (FileSystem.exists(projectDataPath)) projectText = File.getContent(projectDataPath);
            if (FileSystem.exists(levelDataPath)) levelText = File.getContent(levelDataPath);
        } catch (e:Dynamic) { trace("Error loading Ogmo files: " + e); }
        #end

        projectText = sanitizeJson(projectText);
        levelText = sanitizeJson(levelText);

        if (projectText.length > 0) {
            try { project = Json.parse(projectText); } catch (e:Dynamic) { project = {}; }
        } else { project = {}; }

        if (levelText.length > 0) {
            try { level = Json.parse(levelText); } catch (e:Dynamic) { level = {}; }
        } else { level = {}; }
    }

    static function sanitizeJson(json:String):String {
        if (json == null) return "";
        var buf = new StringBuf();
        for (i in 0...json.length) {
            var code = json.charCodeAt(i);
            if (code >= 32 || code == 9 || code == 10 || code == 13) {
                buf.addChar(code);
            }
        }
        return buf.toString();
    }

    static function getProp(obj:Dynamic, key:String):Dynamic {
        if (obj == null) return null;
        if (Reflect.hasField(obj, key)) return Reflect.field(obj, key);
        if (Reflect.hasField(obj, key + " ")) return Reflect.field(obj, key + " ");
        for (f in Reflect.fields(obj)) {
            if (f.trim() == key) return Reflect.field(obj, f);
        }
        return null;
    }

    public function loadTilemap(tileGraphic:String, tileLayer:String = "tiles", tileSize:Int = 16):CitroTilemap {
        var tilemap = new CitroTilemap(0, 0, tileSize);
        var layer = getTileLayer(level, tileLayer);
        if (layer == null) {
            trace("Warning: Tile layer '" + tileLayer + "' not found.");
            return tilemap;
        }
        
        tilemap.widthInTiles = Std.int(getProp(layer, "gridCellsX"));
        tilemap.heightInTiles = Std.int(getProp(layer, "gridCellsY"));
        tilemap.tileSize = tileSize;
        tilemap.data = [];
        
        for (y in 0...tilemap.heightInTiles) {
            var row = [];
            for (x in 0...tilemap.widthInTiles) row.push(0);
            tilemap.data.push(row);
        }

        var arrayMode:Int = Std.int(getProp(layer, "arrayMode"));
        if (arrayMode == 0) {
            var data:Array<Int> = cast getProp(layer, "data");
            if (data != null) {
                for (i in 0...data.length) {
                    tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = data[i];
                }
            }
        } else if (arrayMode == 1) {
            var data2D:Array<Array<Int>> = cast getProp(layer, "data2D");
            if (data2D != null) {
                for (y in 0...data2D.length) {
                    for (x in 0...data2D[y].length) {
                        tilemap.data[y][x] = data2D[y][x];
                    }
                }
            }
        }
        return tilemap;
    }

    public function loadEntities(entityLoadCallback:Dynamic->Void, entityLayer:String = "entities"):Void {
        var layer = getEntityLayer(level, entityLayer);
        if (layer != null) {
            var entities:Array<Dynamic> = cast getProp(layer, "entities");
            if (entities != null) {
                for (entity in entities) entityLoadCallback(entity);
            }
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null) return null;
        var layers:Array<Dynamic> = cast getProp(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(getProp(layer, "name"));
                if (layerName != null && layerName.trim() == name) return layer;
            }
        }
        return null;
    }

    static function getEntityLayer(data:Dynamic, name:String):Dynamic {
        if (data == null) return null;
        var layers:Array<Dynamic> = cast getProp(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(getProp(layer, "name"));
                if (layerName != null && layerName.trim() == name) return layer;
            }
        }
        return null;
    }
}