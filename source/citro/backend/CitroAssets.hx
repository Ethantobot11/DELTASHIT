package citro.backend;

import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;

class CitroAssets {
    macro public static function buildFileReferences(localDir:String = "assets/", subDirectories:Bool = true):Array<Field> {
        var fields = Context.getBuildFields();
        
        function scan(currentDir:String, romfsPrefix:String) {
            if (!FileSystem.exists(currentDir)) {
                Context.warning('Directory "$currentDir" does not exist on host. Asset paths will not be generated.', Context.currentPos());
                return;
            }
            for (item in FileSystem.readDirectory(currentDir)) {
                var fullPath = currentDir + item;
                if (FileSystem.isDirectory(fullPath)) {
                    if (subDirectories) scan(fullPath + "/", romfsPrefix + item + "/");
                } else {
                    var fieldName = item.split(".").join("__");
                    fieldName = fieldName.split("-").join("_");
                    fieldName = fieldName.split(" ").join("_");
                    
                    if (!~/^[a-zA-Z_]/.match(fieldName)) {
                        fieldName = "_" + fieldName;
                    }
                    
                    var romfsPath = romfsPrefix + item;
                    
                    fields.push({
                        name: fieldName,
                        doc: null,
                        meta: [],
                        access: [APublic, AStatic, AInline],
                        kind: FVar(macro : String, macro $v{romfsPath}),
                        pos: Context.currentPos()
                    });
                }
            }
        }
        
        var cleanDir = localDir.endsWith("/") ? localDir : localDir + "/";
        scan(cleanDir, "romfs:/" + cleanDir);
        return fields;
    }
}