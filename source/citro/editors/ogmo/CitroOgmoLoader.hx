package citro.editors.ogmo;

import citro.object.CitroTilemap;
import haxe.Json;
import openfl.Assets;
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
        if (FileSystem.exists(projectDataPath)) projectText = File.getContent(projectDataPath);
        else #end
        projectText = Assets.getText(projectDataPath);

        #if sys
        if (FileSystem.exists(levelDataPath)) levelText = File.getContent(levelDataPath);
        else #end
        levelText = Assets.getText(levelDataPath);

        project = Json.parse(projectText);
        level = Json.parse(levelText);
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
            for (entity in layer.entities) entityLoadCallback(entity);
        }
    }

    static function getTileLayer(data:Dynamic, name:String):Dynamic {
        for (layer in data.layers) if (layer.name == name) return layer;
        return null;
    }

    static function getEntityLayer(data:Dynamic, name:String):Dynamic {
        for (layer in data.layers) if (layer.name == name) return layer;
        return null;
    }
}