package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;
using citro.editors.ogmo.CitroOgmoLoader;

class CitroOgmoLoader {
    public var project:ProjectData;
    public var level:LevelData;

    public function new(projectDataPath:String, levelDataPath:String) {
        var projectText = "";
        var levelText = "";

        #if sys
        try {
            if (FileSystem.exists(projectDataPath)) projectText = File.getContent(projectDataPath);
            if (FileSystem.exists(levelDataPath)) levelText = File.getContent(levelDataPath);
        } catch (e:Dynamic) { 
            trace("Error loading Ogmo files: " + e); 
        }
        #end

        projectText = sanitizeJson(projectText);
        levelText = sanitizeJson(levelText);

        if (projectText.length > 0) {
            try { project = cast Json.parse(projectText); } 
            catch (e:Dynamic) { trace("Project JSON parse error: " + e); project = cast {}; }
        } else { 
            trace("Project text is empty"); 
            project = cast {}; 
        }

        if (levelText.length > 0) {
            try { level = cast Json.parse(levelText); } 
            catch (e:Dynamic) { trace("Level JSON parse error: " + e); level = cast {}; }
        } else { 
            trace("Level text is empty"); 
            level = cast {}; 
        }
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
        var tilemap = new CitroTilemap(0, 0, tileSize);
        var layer = level.getTileLayer(tileLayer);
        
        if (layer == null) {
            trace("Warning: Tile layer '" + tileLayer + "' not found.");
            return tilemap;
        }

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
                tilemap.data[Math.floor(i / tilemap.widthInTiles)][i % tilemap.widthInTiles] = layer.data[i];
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
        var layer = level.getEntityLayer(entityLayer);
        if (layer != null && layer.entities != null) {
            for (entity in layer.entities) {
                entityLoadCallback(entity);
            }
        }
    }

    public static function getTileLayer(data:LevelData, name:String):TileLayer {
        if (data == null || data.layers == null) return null;
        for (layer in data.layers) {
            if (layer.name.trim() == name) return cast layer;
        }
        return null;
    }

    public static function getEntityLayer(data:LevelData, name:String):EntityLayer {
        if (data == null || data.layers == null) return null;
        for (layer in data.layers) {
            if (layer.name.trim() == name) return cast layer;
        }
        return null;
    }

    public static function getTilesetData(data:ProjectData, name:String):ProjectTilesetData {
        if (data == null || data.tilesets == null) return null;
        for (tileset in data.tilesets) {
            if (tileset.label.trim() == name) return cast tileset;
        }
        return null;
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