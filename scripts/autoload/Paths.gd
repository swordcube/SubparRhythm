extends Node

func validate_exts(path:String, exts:Array[String]):
	for ext in exts:
		var p:String = "%s%s" % [path, ext]
		if ResourceLoader.exists(p):
			return p
	return "%s%s" % [path, exts[0] if exts.size() > 0 else ""]

func asset(name:String, directory:String = ""):
	return "assets/%s%s" % [directory+"/" if directory != null and directory.length() > 0 else "", name]

func sound(name:String, directory:String = ""):
	return validate_exts(asset(name, directory), [".mp3", ".ogg", ".wav"])

func json(name:String, directory:String = ""):
	return asset("%s.json" % [name], directory)
