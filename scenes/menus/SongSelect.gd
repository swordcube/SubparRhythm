extends Node2D

var tween = Tween.new()

onready var bg = $BG
onready var strip = $Strip
onready var songNodes = $Songs
onready var music = $music

var curSelected:int = 0

var songs:Dictionary = {}

var noSongs:bool = false

var songTemplate:Node2D = preload("res://scenes/ui/songSelect/songUI.tscn").instance()

func _ready():
	spawnSongs()
			
	$NoSongs.visible = songs.keys().size() <= 0
	
	bg.modulate = Color.white
	add_child(tween)
	tween.interpolate_property(bg, "modulate", bg.modulate, Color("4b4b4b"), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(strip, "position:y", strip.position.y, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.25)
	tween.start()
	
	changeSelection()
	add_child(tween)
	
func _process(delta):
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		Global.songToLoad = songs.keys()[curSelected]
		var songNode = songNodes.get_child(curSelected)
		Global.songDifficulty = songNode.difficulties[songNode.curSelected].to_lower()
		SceneManager.switchScene("gameplay/Gameplay")
	
func spawnSongs():
	var i:int = 0
	var songList:Array = Global.listFilesInDirectory("res://assets/songs")
	for song in songList:
		var difficulties:Array = Global.getTXT("res://assets/songs/"+song+"/difficulties.txt").split("\n")
		if difficulties.size() > 0:
			print("ADDED SONG")
			var newSong = songTemplate.duplicate()
			newSong.difficulties = difficulties
			newSong.targetY = i
			newSong.positionUI(true)
			newSong.position.x = 1888
			var bgTexture:StreamTexture = load(Global.imagePath("res://assets/songs/"+song+"/bg"))
			if bgTexture == null:
				bgTexture = load("res://assets/images/defaultSongBG.png")
			newSong.background = bgTexture
			songs[song] = difficulties
			songNodes.add_child(newSong)
			var songBanner:Sprite = newSong.banner
			songBanner.texture = load(Global.imagePath("res://assets/songs/"+song+"/banner"))
			if songBanner.texture == null:
				songBanner.texture = load("res://assets/images/defaultSongBanner.png")
			i += 1
		yield(get_tree().create_timer(0.5),"timeout")
		
func changeSelection(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = songNodes.get_child_count() - 1
	if curSelected > songNodes.get_child_count() - 1:
		curSelected = 0
		
	tween.stop_all()
		
	var songToLoad:String = Global.chartSongPath(songs.keys()[curSelected])
	print("LOADING MUSIC: " + songToLoad)
	music.stop()
	music.stream = load(songToLoad)
	music.volume_db = -50
	music.play()
	
	tween.interpolate_property(music, "volume_db", music.volume_db, -10, 2.5)
	tween.start()

	bg.texture = songNodes.get_child(curSelected).background
		
	for i in songNodes.get_child_count():
		songNodes.get_child(i).targetY = i-curSelected
		
	Audio.playSFX("scroll")
