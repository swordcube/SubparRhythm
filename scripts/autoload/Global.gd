extends Node

var songSpeed:float = 1
var scrollSpeed:float = 3400.0
var songData:SongData = SongData.new()
var currentSkin:String = "default"
var songToLoad:String = "Example Song"
var songDifficulty:String = "Example Difficulty"

var botPlay:bool = false

var audioExtensions:Array = [".ogg", ".mp3", ".wav"]
var imageExtensions:Array = [".png", ".jpg", ".jpeg", ".webp"]

func _ready() -> void:
	Discord.init()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		OS.set_window_fullscreen(!OS.window_fullscreen)

func getTXT(path):
	var f = File.new()
	var error = f.open(path, File.READ)
	
	if error == OK:
		var text = f.get_as_text()
		f.close()
		return text
	
	print("ERROR LOADING " + path + " RETURNING EMPTY STRING!")
	
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

func pathFromCurSkin(path:String):
	return "res://scenes/ui/skins/"+currentSkin+"/"+path
	
func pathFromSkin(path:String, skin:String):
	return "res://scenes/ui/skins/"+skin+"/"+path
	
func imageFromCurSkin(path:String):
	return getPathFromExtensions("res://assets/images/ui/skins/" + currentSkin + "/" + path, imageExtensions)
	
func imageFromSkin(path:String, skin:String):
	return getPathFromExtensions("res://assets/images/ui/skins/" + skin + "/" + path, imageExtensions)
	
func chartPath(song:String):
	return "res://assets/songs/"+song+"/" + songDifficulty + ".src"
	
func chartSongPath(song:String):
	return getPathFromExtensions("res://assets/songs/" + song + "/music", audioExtensions)

func getPathFromExtensions(original_path:String, extensions:Array) -> String:
	for extension in extensions:
		if ResourceLoader.exists(original_path + extension):
			return original_path + extension
	
	return original_path

func seconds_to_string(seconds: float = 0.0) -> String:
	var timeString: String = str(int(seconds / 60)) + ":"
	var timeStringHelper: int = int(seconds) % 60
	
	if timeStringHelper < 10:
		timeString += "0"
	
	timeString += str(timeStringHelper)
	
	return timeString
