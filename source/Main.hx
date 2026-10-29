package;

import citro.CitroGame;
import citro.CitroG;
import haxe3ds.services.GFX;
import haxe3ds.services.RomFS;
import CrashHandler;

class Main {
    public function new() {
        #if haxe3ds
        GFX.init();
        RomFS.init();
        Sys.println("1. Services initialized.");

        try {
            if (!sys.FileSystem.exists("sdmc:/DELTASHIT/Logs")) {
                sys.FileSystem.createDirectory("sdmc:/DELTASHIT/Logs");
                Sys.println("2. Created directory: sdmc:/DELTASHIT/Logs");
            } else {
                Sys.println("2. Log directory already exists.");
            }
        } catch(e:Dynamic) {
            Sys.println("2. Warning/Error creating dir: " + e);
        }
        Sys.println("3. Boot test successful!");
        #end

        CrashHandler.init();
        
        #if DISCORD_ALLOWED
        DiscordClient.prepare();
        #end

        CitroGame.start(new MenuState());
    }
}