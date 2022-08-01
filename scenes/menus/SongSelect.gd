extends Node2D

var tween = Tween.new()
var volume_tween = Tween.new()

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
	add_child(volume_tween)
	
	tween.interpolate_property(bg, "modulate", bg.modulate, Color("4b4b4b"), 1, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.interpolate_property(strip, "position:y", strip.position.y, 0, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.25)
	tween.start()
	
	changeSelection()
	
	yield(get_tree().create_timer(0.25), "timeout")
	
	Discord.update_presence("Selecting songs")
	
	TimeManager.connect("beatHit", self, "beatHit")
	
func _process(delta):
	TimeManager.position = music.get_playback_position()*1000.0
	bg.scale = lerp(bg.scale, Vector2.ONE, delta * 5)
	if Input.is_action_just_pressed("ui_up"):
		changeSelection(-1)
		
	if Input.is_action_just_pressed("ui_down"):
		changeSelection(1)
		
	if Input.is_action_just_pressed("ui_accept"):
		Global.songToLoad = songs.keys()[curSelected]
		
		var songNode = songNodes.get_child(curSelected)
		Global.songBackground = songNode.background
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
			newSong.position.x = 1888 + (i * (590 * 4))
			
			var bgTexture:StreamTexture = load(Global.getPathFromExtensions("res://assets/songs/" + song + "/bg", Global.imageExtensions))
			
			if bgTexture == null:
				bgTexture = load("res://assets/images/defaultSongBG.png")
			
			newSong.background = bgTexture
			songs[song] = difficulties
			songNodes.add_child(newSong)
			
			var songBanner:Sprite = newSong.banner
			songBanner.texture = load(Global.getPathFromExtensions("res://assets/songs/" + song + "/banner", Global.imageExtensions))
			
			if songBanner.texture == null:
				songBanner.texture = load("res://assets/images/defaultSongBanner.png")
			
			i += 1

func changeSelection(change:int = 0):
	curSelected += change
	
	if curSelected < 0:
		curSelected = songNodes.get_child_count() - 1
	if curSelected > songNodes.get_child_count() - 1:
		curSelected = 0
	
	volume_tween.stop_all()
	
	var songToLoad:String = Global.chartSongPath(songs.keys()[curSelected])
	
	print("LOADING MUSIC: " + songToLoad)
	
	music.stop()
	music.stream = load(songToLoad)
	music.volume_db = -50
	music.play()
	
	volume_tween.interpolate_property(music, "volume_db", music.volume_db, -10, 2.5)
	volume_tween.start()

	bg.modulate = Color.black
	tween.stop_all()
	tween.interpolate_property(bg, "modulate", bg.modulate, Color("4b4b4b"), 0.5, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	tween.start()
	bg.texture = songNodes.get_child(curSelected).background
	
	for i in songNodes.get_child_count():
		songNodes.get_child(i).targetY = i-curSelected
	
	Audio.playSFX("scroll")
	
	Discord.update_presence("Selecting a song", "Selected: " + songs.keys()[curSelected])

	Global.songDifficulty = songNodes.get_child(curSelected).difficulties[songNodes.get_child(curSelected).curSelected].to_lower()
	Global.loadChartBPM(songs.keys()[curSelected])
	TimeManager.changeBPM(TimeManager.bpm)
	TimeManager.recalculateValues()

func beatHit():
	bg.scale = Vector2(1.02, 1.02)
