extends Node

var songSpeed:float = 1
var scrollSpeed:float = 3400.0
var songData:SongData = SongData.new()
var currentSkin:String = "default"
var songToLoad:String = "Ballistic Remaster"
var songDifficulty:String = "hard"

var botPlay:bool = false

func getTXT(path):
	var f = File.new()
	var error = f.open(path, File.READ)
	if error == OK:
		var text = f.get_as_text()
		f.close()
		return text
		
	print("ERROR LOADING "+path+" RETURNING EMPTY STRING!")
	return ""

func listFilesInDirectory(path):
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()

	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif not file.begins_with("."):
			files.append(file)

	dir.list_dir_end()

	return files

func imagePath(path:String):
	var f = File.new()
	var realPath:String = path
	var imageExts:PoolStringArray = [
		".jpg",
		".jpeg",
		".png",
	]
	
	for ext in imageExts:
		if f.file_exists(realPath+ext):
			return realPath+ext
			
	return ""

func pathFromCurSkin(path:String):
	return "res://scenes/ui/skins/"+currentSkin+"/"+path
	
func pathFromSkin(path:String, skin:String):
	return "res://scenes/ui/skins/"+skin+"/"+path
	
func imageFromCurSkin(path:String):
	return "res://assets/images/ui/skins/"+currentSkin+"/"+path+".png"
	
func imageFromSkin(path:String, skin:String):
	return "res://assets/images/ui/skins/"+skin+"/"+path+".png"
	
func chartPath(song:String):
	return "res://assets/songs/"+song+"/" + songDifficulty + ".src"
	
func chartSongPath(song:String):
	if File.new().file_exists("res://assets/songs/"+song+"/music.mp3"):
		return "res://assets/songs/"+song+"/music.mp3"
	else:
		return "res://assets/songs/"+song+"/music.ogg"
