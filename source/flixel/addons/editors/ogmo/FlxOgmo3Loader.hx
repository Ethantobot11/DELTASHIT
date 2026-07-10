package flixel.addons.editors.ogmo;

#if !wiiu
import flixel.FlxG;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;
import flixel.tile.FlxTilemap;
import flixel.util.FlxArrayUtil;
import haxe.Json;
import openfl.Assets;

using StringTools;
using flixel.addons.editors.ogmo.FlxOgmo3Loader;

/**
 * @since 2.8.0
 */
class FlxOgmo3Loader
{
	var project:ProjectData;
	var level:LevelData;

	public function new(projectData:String, levelData:String)
	{
		project = Assets.getText(projectData).parseProjectJSON();
		level = Assets.getText(levelData).parseLevelJSON();
	}

	public function getLevelValue(value:String):Dynamic
	{
		return Reflect.field(level.values, value);
	}

	public function loadTilemap(tileGraphic:FlxTilemapGraphicAsset, tileLayer:String = "tiles", ?tilemap:FlxTilemap):FlxTilemap
	{
		if (tilemap == null)
			tilemap = new FlxTilemap();

		var layer = level.getTileLayer(tileLayer);
		var tileset = project.getTilesetData(layer.tileset);
		switch (layer.arrayMode)
		{
			case 0:
				tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileGraphic, tileset.tileWidth, tileset.tileHeight);
			case 1:
				tilemap.loadMapFrom2DArray(layer.data2D, tileGraphic, tileset.tileWidth, tileset.tileHeight);
		}
		return tilemap;
	}

	public function loadTilemapExt(tileGraphic:FlxTilemapGraphicAsset, tileLayer:String = "tiles", ?tilemap:FlxTilemapExt):FlxTilemapExt
	{
		if (tilemap == null)
			tilemap = new FlxTilemapExt();

		var layer = level.getTileLayer(tileLayer);
		var tileset = project.getTilesetData(layer.tileset);
		switch (layer.arrayMode)
		{
			case 0:
				tilemap.loadMapFromArray(layer.data, layer.gridCellsX, layer.gridCellsY, tileGraphic, tileset.tileWidth, tileset.tileHeight);
				if (layer.tileFlags != null)
				{
					applyFlagsToTilemapExt(layer.tileFlags, tilemap);
				}

			case 1:
				tilemap.loadMapFrom2DArray(layer.data2D, tileGraphic, tileset.tileWidth, tileset.tileHeight);
				if (layer.tileFlags2D != null)
				{
					applyFlagsToTilemapExt(FlxArrayUtil.flatten2DArray(layer.tileFlags2D), tilemap);
				}
		}
		return tilemap;
	}

	public function loadGridMap(gridLayer:String = "grid"):Map<String, Array<FlxPoint>>
	{
		var gridLayer = level.getGridLayer(gridLayer);
		var out = new Map<String, Array<FlxPoint>>();
		switch (gridLayer.arrayMode)
		{
			case 0:
				for (i in 0...gridLayer.grid.length)
				{
					if (!out.exists(gridLayer.grid[i]))
						out.set(gridLayer.grid[i], []);
					out[gridLayer.grid[i]].push(FlxPoint.get((i % gridLayer.gridCellsX) * gridLayer.gridCellWidth,
						Math.floor(i / gridLayer.gridCellsX) * gridLayer.gridCellHeight));
				}
			case 1:
				for (j in 0...gridLayer.grid2D.length)
					for (i in 0...gridLayer.grid2D[j].length)
					{
						if (!out.exists(gridLayer.grid2D[j][i]))
							out.set(gridLayer.grid2D[j][i], []);
						out[gridLayer.grid2D[j][i]].push(FlxPoint.get(i * gridLayer.gridCellWidth, j * gridLayer.gridCellHeight));
					}
		}
		return out;
	}

	public function loadEntities(entityLoadCallback:EntityData->Void, entityLayer:String = "entities"):Void
	{
		for (entity in level.getEntityLayer(entityLayer).entities)
			entityLoadCallback(entity);
	}

	public function loadDecals(decalLayer:String = 'decals', decalsPath:String):FlxGroup
	{
		if (!decalsPath.endsWith('/'))
			decalsPath += '/';
		var g = new FlxGroup();
		for (decal in level.getDecalLayer(decalLayer).decals)
		{
			var s = new FlxSprite(decal.x, decal.y, decalsPath + decal.texture);
			s.offset.set(s.width / 2, s.height / 2);
			if (decal.scaleX != null)
				s.scale.x = decal.scaleX;
			if (decal.scaleY != null)
				s.scale.y = decal.scaleY;
			if (decal.rotation != null)
				s.angle = project.anglesRadians ? FlxAngle.asDegrees(decal.rotation) : decal.rotation;
			g.add(s);
		}
		return g;
	}

	static function parseLevelJSON(json:String):LevelData
	{
		return cast Json.parse(json);
	}

	static function parseProjectJSON(json:String):ProjectData
	{
		return cast Json.parse(json);
	}

	static function getTileLayer(data:LevelData, name:String):TileLayer
	{
		for (layer in data.layers)
			if (layer.name == name)
				return cast layer;
		return null;
	}

	static function getGridLayer(data:LevelData, name:String):GridLayer
	{
		for (layer in data.layers)
			if (layer.name == name)
				return cast layer;
		return null;
	}

	static function getEntityLayer(data:LevelData, name:String):EntityLayer
	{
		for (layer in data.layers)
			if (layer.name == name)
				return cast layer;
		return null;
	}

	static function getDecalLayer(data:LevelData, name:String):DecalLayer
	{
		for (layer in data.layers)
			if (layer.name == name)
				return cast layer;
		return null;
	}

	static function getTilesetData(data:ProjectData, name:String):ProjectTilesetData
	{
		for (tileset in data.tilesets)
			if (tileset.label == name)
				return tileset;
		return null;
	}

	static function applyFlagsToTilemapExt(tileFlags:Array<Int>, tilemap:FlxTilemapExt)
	{
		var specialTiles = new Array<FlxTileSpecial>();

		for (i in 0...tileFlags.length)
		{
			var flag = tileFlags[i];
			#if (flixel < version("5.9.0"))
			var specialTile = new FlxTileSpecial(tilemap.getTileByIndex(i), false, false, 0);
			#else
			var specialTile = new FlxTileSpecial(tilemap.getTileIndex(i), false, false, 0);
			#end

			if (flag & 4 > 0)
				specialTile.flipX = true;
			if (flag & 2 > 0)
				specialTile.flipY = true;
			if (flag & 1 > 0)
			{
				if (specialTile.flipY)
				{
					specialTile.flipY = false;
					specialTile.rotate = FlxTileSpecial.ROTATE_270;
				}
				else
				{
					specialTile.flipX = !specialTile.flipX;
					specialTile.rotate = FlxTileSpecial.ROTATE_90;
				}
			}
			specialTiles.push(specialTile);
		}
		tilemap.setSpecialTiles(specialTiles);
	}
}

typedef ProjectData =
{
	name:String,
	levelPaths:Array<String>,
	backgroundColor:String,
	gridColor:String,
	anglesRadians:Bool,
	directoryDepth:Int,
	levelDefaultSize:Point,
	levelMinSize:Point,
	levelMaxSize:Point,
	levelValues:Array<Dynamic>,
	defaultExportMode:String,
	entityTags:Array<String>,
	layers:Array<ProjectLayerData>,
	entities:Array<ProjectEntityData>,
	tilesets:Array<ProjectTilesetData>,
}

typedef ProjectLayerData =
{
	definition:String,
	name:String,
	gridSize:Point,
	exportID:String,
	?requiredTags:Array<String>,
	?excludedTags:Array<String>,
	?exportMode:Int,
	?arrayMode:Int,
	?defaultTileset:String,
	?folder:String,
	?includeImageSequence:Bool,
	?scaleable:Bool,
	?rotatable:Bool,
	?values:Array<Dynamic>,
	?legend:Dynamic,
}

typedef ProjectEntityData =
{
	exportID:String,
	name:String,
	limit:Int,
	size:Point,
	origin:Point,
	originAnchored:Bool,
	shape:
	{
		label:String, points:Array<Point>
	},
	color:String,
	tileX:Bool,
	tileY:Bool,
	tileSize:Point,
	resizeableX:Bool,
	resizeableY:Bool,
	rotatable:Bool,
	rotationDegrees:Int,
	canFlipX:Bool,
	canFlipY:Bool,
	canSetColor:Bool,
	hasNodes:Bool,
	nodeLimit:Int,
	nodeDisplay:Int,
	nodeGhost:Bool,
	tags:Array<String>,
	values:Array<Dynamic>,
}

typedef ProjectTilesetData =
{
	label:String,
	path:String,
	image:String,
	tileWidth:Int,
	tileHeight:Int,
	tileSeparationX:Int,
	tileSeparationY:Int,
}

typedef LevelData =
{
	width:Int,
	height:Int,
	offsetX:Int,
	offsetY:Int,
	layers:Array<LayerData>,
	?values:Dynamic,
}

typedef LayerData =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	?entities:Array<EntityData>,
	?decals:Array<DecalData>,
	?tileset:String,
	?data:Array<Int>,
	?data2D:Array<Array<Int>>,
	?dataCSV:String,
	?exportMode:Int,
	?arrayMode:Int,
}

typedef TileLayer =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	tileset:String,
	exportMode:Int,
	arrayMode:Int,
	?data:Array<Int>,
	?tileFlags:Array<Int>,
	?data2D:Array<Array<Int>>,
	?tileFlags2D:Array<Array<Int>>,
	?dataCSV:String,
	?dataCoords:Array<Array<Int>>,
	?dataCoords2D:Array<Array<Array<Int>>>,
}

typedef GridLayer =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	arrayMode:Int,
	?grid:Array<String>,
	?grid2D:Array<Array<String>>,
}

typedef EntityLayer =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	entities:Array<EntityData>,
}

typedef EntityData =
{
	name:String,
	id:Int,
	_eid:String,
	x:Int,
	y:Int,
	?width:Int,
	?height:Int,
	?originX:Int,
	?originY:Int,
	?rotation:Float,
	?flippedX:Bool,
	?flippedY:Bool,
	?nodes:Array<{x:Float, y:Float}>,
	?values:Dynamic,
}

typedef DecalLayer =
{
	name:String,
	_eid:String,
	offsetX:Int,
	offsetY:Int,
	gridCellWidth:Int,
	gridCellHeight:Int,
	gridCellsX:Int,
	gridCellsY:Int,
	decals:Array<DecalData>,
}

typedef DecalData =
{
	x:Int,
	y:Int,
	texture:String,
	?scaleX:Float,
	?scaleY:Float,
	?rotation:Float,
}

typedef Point =
{
	x:Int,
	y:Int
}
#end
