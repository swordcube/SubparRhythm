extends Node2D

var tween = Tween.new()

onready var bg = $BG
onready var strip = $Strip

var songs:Dictionary = {}

var noSongs:bool = false

func _ready():
	#i'ma do this tmr
	var songList:Array = Global.listFilesInDirectory("res://assets/songs")
	
	bg.modulate = Color.white
	add_child(tween)
	tween.interpolate_property(bg, "modulate", bg.modulate, Color("4b4b4b"), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(strip, "position:y", strip.position.y, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.25)
	tween.start()
