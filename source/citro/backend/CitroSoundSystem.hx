package citro.backend;

class CitroG.sound.loadSystem {
    public var volume:Float = 1.0;
    public var muted:Bool = false;

    public function new() {
        #if (!wiiu || !cafe)
        untyped __cpp__("cwavUseEnvironment(0)");
        #end
    }

    /**
     * Loads and immediately plays a sound.
     * @param path The path to the .cwav or .bcwav file.
     * @param volume Optional volume override (0.0 to 1.0).
     * @param looped Whether the sound should loop (Note: depends on CWAV file encoding).
     * @return The CitroG.sound.load instance.
     */
    public function play(path:String, ?volume:Float = 1.0, ?looped:Bool = false):CitroG.sound.load {
        var sound = new CitroG.sound.load(path);
        sound.volume = muted ? 0.0 : (volume != null ? volume : this.volume);
        sound.looped = looped;
        sound.play();
        return sound;
    }

    /**
     * Loads a sound into memory without playing it immediately.
     * @param path The path to the .cwav or .bcwav file.
     * @return The CitroG.sound.load instance.
     */
    public function load(path:String):CitroG.sound.load {
        var sound = new CitroG.sound.load(path);
        sound.volume = muted ? 0.0 : this.volume;
        return sound;
    }
}