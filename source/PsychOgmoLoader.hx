package;

#if !wiiu
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import funk.PsychFile;
import haxe.Json;

using flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PsychOgmoLoader extends FlxOgmo3Loader
{
	public function new(projectDataPath:String, levelDataPath:String)
	{
		final rawProjectText = PsychFile.getContent(projectDataPath);
		final rawLevelText = PsychFile.getContent(levelDataPath);

		final parsedProject:ProjectData = cast Json.parse(rawProjectText);
		final parsedLevel:LevelData = cast Json.parse(rawLevelText);

		super(projectDataPath, levelDataPath);

		@:privateAccess this.project = parsedProject;
		@:privateAccess this.level = parsedLevel;
	}
}
#end
