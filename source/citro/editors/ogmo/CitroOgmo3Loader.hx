package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CitroOgmo3Loader {
    public var project:Dynamic;
    public var level:Dynamic;

    public function new(projectDataPath:String, levelDataPath:String) {
        var rawProjectText = "";
        var rawLevelText = "";

        #if sys
        try {
            if (FileSystem.exists(projectDataPath)) rawProjectText = File.getContent(projectDataPath);
            if (FileSystem.exists(levelDataPath)) rawLevelText = File.getContent(levelDataPath);
        } catch (e:Dynamic) { 
            trace("Error loading Ogmo files: " + e); 
        }
        #end

        var projectText = sanitizeJson(rawProjectText);
        var levelText = sanitizeJson(rawLevelText);

        if (projectText.length > 0) {
            try { project = Json.parse(projectText); } 
            catch (e:Dynamic) { project = {}; }
        } else { project = {}; }

        if (levelText.length > 0) {
            try { level = Json.parse(levelText); } 
            catch (e:Dynamic) { level = {}; }
        } else { level = {}; }
    }

    static function getFieldTrimmed(obj:Dynamic, key:String):Dynamic {
        if (obj == null) return null;
        if (Reflect.hasField(obj, key)) return Reflect.field(obj, key);
        for (f in Reflect.fields(obj)) {
            if (f.trim() == key) return Reflect.field(obj, f);
        }
        return null;
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

    public function loadTilemap(tileGraphic:String, tileLayer:String = "tiles", tileSize:Int = 16):CitroTilemap {
        var layer = getTileLayer(level, tileLayer);
        if (layer == null) {
            trace("Warning: Tile layer '" + tileLayer + "' not found.");
            return new CitroTilemap(0, 0, tileSize);
        }

        var gridCellsX:Int = Std.int(getFieldTrimmed(layer, "gridCellsX"));
        var gridCellsY:Int = Std.int(getFieldTrimmed(layer, "gridCellsY"));
        
        var tilemap = new CitroTilemap(gridCellsX, gridCellsY, tileSize);
        tilemap.loadGraphic(tileGraphic);

        var arrayMode:Int = Std.int(getFieldTrimmed(layer, "arrayMode"));
        if (arrayMode == 0 && getFieldTrimmed(layer, "data") != null) {
            var data:Array<Int> = cast getFieldTrimmed(layer, "data");
            if (data != null) {
                for (i in 0...data.length) {
                    tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = data[i];
                }
            }
        } else if (arrayMode == 1 && getFieldTrimmed(layer, "data2D") != null) {
            var data2D:Array<Array<Int>> = cast getFieldTrimmed(layer, "data2D");
            if (data2D != null) {
                for (y in 0...data2D.length) {
                    for (x in 0...data2D[y].length) {
                        tilemap.data[y][x] = data2D[y][x];
                    }
                }
            }
        } else if (getFieldTrimmed(layer, "dataCSV") != null) {
            var dataCSV:String = cast getFieldTrimmed(layer, "dataCSV");
            if (dataCSV != null) tilemap.loadMapFromCSV(dataCSV, tileSize);
        }

        return tilemap;
    }

    public function loadEntities(entityLoadCallback:Dynamic->Void, entityLayer:String = "entities"):Void {
        if (level == null || !Reflect.hasField(level, "layers")) return;
        
        var layers:Array<Dynamic> = cast Reflect.field(level, "layers");
        var layer:Dynamic = null;
        
        for (l in layers) {
            var name:String = Std.string(getFieldTrimmed(l, "name"));
            if (name != null && name.trim() == entityLayer) {
                layer = l;
                break;
            }
        }

        if (layer != null && getFieldTrimmed(layer, "entities") != null) {
            var entities:Array<Dynamic> = cast getFieldTrimmed(layer, "entities");
            if (entities != null) {
                for (entity in entities) entityLoadCallback(entity);
            }
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = cast Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(getFieldTrimmed(layer, "name"));
                if (layerName != null && layerName.trim() == name) return layer;
            }
        }
        return null;
    }

    static function getEntityLayer(data:Dynamic, name:String):Dynamic {
        if (data == null || !Reflect.hasField(data, "layers")) return null;
        var layers:Array<Dynamic> = cast Reflect.field(data, "layers");
        if (layers != null) {
            for (layer in layers) {
                var layerName:String = Std.string(getFieldTrimmed(layer, "name"));
                if (layerName != null && layerName.trim() == name) return layer;
            }
        }
        return null;
    }
}