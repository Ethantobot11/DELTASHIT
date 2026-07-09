package;

#if !wiiu
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxAssets.FlxTilemapGraphicAsset;

#if (macro && ios)
@:build(flixel.system.FlxAssets.buildFileReferences("./", true))
#else
@:build(flixel.system.FlxAssets.buildFileReferences("assets", true))
#end
#end

class AssetPaths {
    #if wiiu
    #end
}
