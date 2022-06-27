extends Node

var scrollSpeed:float = 4000.0
var songData:SongData = SongData.new()
var currentSkin:String = "default"
var songToLoad:String = "MC MENTAL @ HIS BEST"
var songDifficulty:String = "challenge"

var botPlay:bool = false

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
