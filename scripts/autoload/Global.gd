extends Node

var songSpeed:float = 1
var scrollSpeed:float = 3400.0
var songData:SongData = SongData.new()
var currentSkin:String = "default"
var songToLoad:String = "Ballistic Remaster"

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
	return "res://assets/songs/"+song+"/hard.src"
	
func chartSongPath(song:String):
	return "res://assets/songs/"+song+"/music.ogg"
