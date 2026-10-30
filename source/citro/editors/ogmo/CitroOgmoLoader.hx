package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

class CitroOgmoLoader {
    public var project:Dynamic;
    public var level:Dynamic;

    public function new(projectDataPath:String, levelDataPath:String) {
        var rawProjectText = "";
        var rawLevelText = "";

        #if sys
        try {
            if (FileSystem.exists(projectDataPath)) {
                rawProjectText = File.getContent(projectDataPath);
            } else {
                trace("Warning: Project file does not exist at: " + projectDataPath);
            }
            if (FileSystem.exists(levelDataPath)) {
                rawLevelText = File.getContent(levelDataPath);
            } else {
                trace("Warning: Level file does not exist at: " + levelDataPath);
            }
        } catch (e:Dynamic) { 
            trace("Error loading Ogmo files: " + e); 
        }
        #end

        var projectText = sanitizeJson(rawProjectText);
        var levelText = sanitizeJson(rawLevelText);

        if (projectText.length > 0) {
            try { 
                project = Json.parse(projectText); 
            } catch (e:Dynamic) { 
                trace("Project JSON parse error: " + e); 
                project = {}; 
            }
        } else { 
            project = {}; 
        }

        if (levelText.length > 0) {
            try { 
                level = Json.parse(levelText); 
            } catch (e:Dynamic) { 
                trace("Level JSON parse error: " + e); 
                level = {}; 
            }
        } else { 
            level = {}; 
        }
    }

    static function getFieldTrimmed(obj:Dynamic, key:String):Dynamic {
        if (obj == null) return null;
        if (Reflect.hasField(obj, key)) return Reflect.field(obj, key);
        for (f in Reflect.fields(obj)) {
            if (f.trim() == key) {
                return Reflect.field(obj, f);
            }
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
            trace("Warning: Tile layer '" + tileLayer + "' not found. Available layers:");
            var layers:Array<Dynamic> = cast Reflect.field(level, "layers");
            if (layers != null) {
                for (l in layers) {
                    trace(" - '" + Reflect.field(l, "name") + "'");
            }
            }
            return new CitroTilemap(0, 0, tileSize);
        }

        var gridCellsX:Int = Std.int(Reflect.field(layer, "gridCellsX"));
        var gridCellsY:Int = Std.int(Reflect.field(layer, "gridCellsY"));
        
        var tilemap = new CitroTilemap(gridCellsX, gridCellsY, tileSize);
        tilemap.loadGraphic(tileGraphic);

        var arrayMode:Int = Std.int(Reflect.field(layer, "arrayMode"));
        if (arrayMode == 0 && Reflect.hasField(layer, "data")) {
            var data:Array<Int> = cast Reflect.field(layer, "data");
            if (data != null) {
                for (i in 0...data.length) {
                    tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = data[i];
                }
            }
        } else if (arrayMode == 1 && Reflect.hasField(layer, "data2D")) {
            var data2D:Array<Array<Int>> = cast Reflect.field(layer, "data2D");
            if (data2D != null) {
                for (y in 0...data2D.length) {
                    for (x in 0...data2D[y].length) {
                        tilemap.data[y][x] = data2D[y][x];
                    }
                }
            }
        } else if (Reflect.hasField(layer, "dataCSV")) {
            var dataCSV:String = cast Reflect.field(layer, "dataCSV");
            if (dataCSV != null) {
                tilemap.loadMapFromCSV(dataCSV, tileSize);
            }
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
                for (entity in entities) {
                    entityLoadCallback(entity);
                }
            }
        }
    }
}

typedef ProjectData = {
    var name:String;
    var levelPaths:Array<String>;
    var backgroundColor:String;
    var gridColor:String;
    var anglesRadians:Bool;
    var directoryDepth:Int;
    var levelDefaultSize:Point;
    var levelMinSize:Point;
    var levelMaxSize:Point;
    var levelValues:Array<Dynamic>;
    var defaultExportMode:String;
    var entityTags:Array<String>;
    var layers:Array<ProjectLayerData>;
    var entities:Array<ProjectEntityData>;
    var tilesets:Array<ProjectTilesetData>;
}

typedef ProjectLayerData = {
    var definition:String;
    var name:String;
    var gridSize:Point;
    var exportID:String;
    @:optional var requiredTags:Array<String>;
    @:optional var excludedTags:Array<String>;
    @:optional var exportMode:Int;
    @:optional var arrayMode:Int;
    @:optional var defaultTileset:String;
    @:optional var folder:String;
    @:optional var includeImageSequence:Bool;
    @:optional var scaleable:Bool;
    @:optional var rotatable:Bool;
    @:optional var values:Array<Dynamic>;
    @:optional var legend:Dynamic;
}

typedef ProjectEntityData = {
    var exportID:String;
    var name:String;
    var limit:Int;
    var size:Point;
    var origin:Point;
    var originAnchored:Bool;
    var shape:{ label:String, points:Array<Point> };
    var color:String;
    var tileX:Bool;
    var tileY:Bool;
    var tileSize:Point;
    var resizeableX:Bool;
    var resizeableY:Bool;
    var rotatable:Bool;
    var rotationDegrees:Int;
    var canFlipX:Bool;
    var canFlipY:Bool;
    var canSetColor:Bool;
    var hasNodes:Bool;
    var nodeLimit:Int;
    var nodeDisplay:Int;
    var nodeGhost:Bool;
    var tags:Array<String>;
    var values:Array<Dynamic>;
}

typedef ProjectTilesetData = {
    var label:String;
    var path:String;
    var image:String;
    var tileWidth:Int;
    var tileHeight:Int;
    var tileSeparationX:Int;
    var tileSeparationY:Int;
}

typedef LevelData = {
    var width:Int;
    var height:Int;
    var offsetX:Int;
    var offsetY:Int;
    var layers:Array<LayerData>;
    @:optional var values:Dynamic;
}

typedef LayerData = {
    var name:String;
    var _eid:String;
    var offsetX:Int;
    var offsetY:Int;
    var gridCellWidth:Int;
    var gridCellHeight:Int;
    var gridCellsX:Int;
    var gridCellsY:Int;
    @:optional var entities:Array<EntityData>;
    @:optional var decals:Array<DecalData>;
    @:optional var tileset:String;
    @:optional var data:Array<Int>;
    @:optional var data2D:Array<Array<Int>>;
    @:optional var dataCSV:String;
    @:optional var exportMode:Int;
    @:optional var arrayMode:Int;
}

typedef TileLayer = {
    var name:String;
    var _eid:String;
    var offsetX:Int;
    var offsetY:Int;
    var gridCellWidth:Int;
    var gridCellHeight:Int;
    var gridCellsX:Int;
    var gridCellsY:Int;
    var tileset:String;
    var exportMode:Int;
    var arrayMode:Int;
    @:optional var data:Array<Int>;
    @:optional var tileFlags:Array<Int>;
    @:optional var data2D:Array<Array<Int>>;
    @:optional var tileFlags2D:Array<Array<Int>>;
    @:optional var dataCSV:String;
    @:optional var dataCoords:Array<Array<Int>>;
    @:optional var dataCoords2D:Array<Array<Array<Int>>>;
}

typedef GridLayer = {
    var name:String;
    var _eid:String;
    var offsetX:Int;
    var offsetY:Int;
    var gridCellWidth:Int;
    var gridCellHeight:Int;
    var gridCellsX:Int;
    var gridCellsY:Int;
    var arrayMode:Int;
    @:optional var grid:Array<String>;
    @:optional var grid2D:Array<Array<String>>;
}

typedef EntityLayer = {
    var name:String;
    var _eid:String;
    var offsetX:Int;
    var offsetY:Int;
    var gridCellWidth:Int;
    var gridCellHeight:Int;
    var gridCellsX:Int;
    var gridCellsY:Int;
    var entities:Array<EntityData>;
}

typedef EntityData = {
    var name:String;
    var id:Int;
    var _eid:String;
    var x:Int;
    var y:Int;
    @:optional var width:Int;
    @:optional var height:Int;
    @:optional var originX:Int;
    @:optional var originY:Int;
    @:optional var rotation:Float;
    @:optional var flippedX:Bool;
    @:optional var flippedY:Bool;
    @:optional var nodes:Array<{x:Float, y:Float}>;
    @:optional var values:Dynamic;
}

typedef DecalLayer = {
    var name:String;
    var _eid:String;
    var offsetX:Int;
    var offsetY:Int;
    var gridCellWidth:Int;
    var gridCellHeight:Int;
    var gridCellsX:Int;
    var gridCellsY:Int;
    var decals:Array<DecalData>;
}

typedef DecalData = {
    var x:Int;
    var y:Int;
    var texture:String;
    @:optional var scaleX:Float;
    @:optional var scaleY:Float;
    @:optional var rotation:Float;
}

typedef Point = {
    var x:Int;
    var y:Int;
}