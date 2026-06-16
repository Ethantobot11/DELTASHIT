package;

import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import funk.PsychFile;
import haxe.Json;

using flixel.addons.editors.ogmo.FlxOgmo3Loader;

class PsychOgmoLoader extends FlxOgmo3Loader
{
    public function new(projectDataPath:String, levelDataPath:String)
    {
        // Use PsychFile to cleanly route around the iOS bundle pathing issues
        final rawProjectText = PsychFile.getContent(projectDataPath);
        final rawLevelText = PsychFile.getContent(levelDataPath);

        // De-serialize the raw text into standard Haxe structures
        final parsedProject:ProjectData = cast Json.parse(rawProjectText);
        final parsedLevel:LevelData = cast Json.parse(rawLevelText);

        // Trick Haxe into bypassing the traditional constructor layout
        super(projectDataPath, levelDataPath);

        // Inject our safely managed runtime values directly into the fields
        @:privateAccess this.project = parsedProject;
        @:privateAccess this.level = parsedLevel;
    }
}