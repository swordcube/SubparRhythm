extends BaseScene

var UI:Node2D

var notesToSpawn:Array = []

var died:bool = false

var accuracy:float = 0.0
var combo:int = 0

var totalHit:float = 0.0
var totalNotes:int = 0

onready var rating = $Rating

var presence_timer: Timer = Timer.new()

onready var start_time: int = int(OS.get_unix_time() / 1000.0)

func _ready():
	Global.songSpeed = clamp(Global.songSpeed, 0.5, 3.0)
	Global.scrollSpeed = clamp(Global.scrollSpeed, 1000.0, 5000.0)
	
	randomize()
	
	var f = File.new()
	var error = f.open(Global.chartPath(Global.songToLoad), File.READ)
	
	if error == OK:
		Global.songData.notes = []
		var array:Array = f.get_as_text().split("\n")
		TimeManager.bpm = float(array[0].split("bpm:")[1])
		array.remove(0)
		while array.size() > 0:
			if len(array[0]) > 0:
				var directionToPush:int = int(array[0].split("direction:")[1])%4
				array.remove(0)
				var positionToPush:float = float(array[0].split("position:")[1])
				array.remove(0)
				var sustainTimeToPush:float = float(array[0].split("sustaintime:")[1])
				array.remove(0)
				Global.songData.notes.append([directionToPush, positionToPush+(AudioServer.get_output_latency() * 1000), sustainTimeToPush])
			else:
				array.remove(0)
	else:
		print("CHART COULD NOT LOAD!! LOL!!!")

	notesToSpawn = Global.songData.notes.duplicate()
		
	UI = load(Global.pathFromCurSkin("UI.tscn")).instance()
	add_child(UI)
	
	remove_child(rating)
	UI.add_child(rating)
	
	TimeManager.position = -2000
	
	add_child(presence_timer)
	
	presence_timer.start(0.5)
# warning-ignore:return_value_discarded
	presence_timer.connect("timeout", self, "presence_update")
	
var startedSong:bool = false

onready var music = $Music
	
func _process(delta):
	if Input.is_action_just_pressed("song_exit"):
		SceneManager.switchScene("menus/SongSelect")
	
	# resync music if it goes off sync
	if not died:
		TimeManager.position += (delta * 1000.0) * Global.songSpeed
		
		if TimeManager.position >= (music.get_playback_position()*1000.0) + 30:
			music.seek(TimeManager.position / 1000.0)
		
	if TimeManager.position >= 0 and not startedSong:
		startedSong = true
		music.stream = load(Global.chartSongPath(Global.songToLoad))
		music.pitch_scale = Global.songSpeed
		music.play(0.0)
		TimeManager.position = 0
		
	if totalHit != 0 and totalNotes != 0:
		accuracy = totalHit / totalNotes
	else:
		accuracy = 0
	
	if not died:
		for note in notesToSpawn:
			var direction:int = int(note[0])
			var notePosition:float = float(note[1])
			var sustainLength:float = float(note[2])
			
			var spawnRadius:float = (1500.0 / (Global.scrollSpeed / 1000.0)) * Global.songSpeed
			
			if not died and TimeManager.position > notePosition - spawnRadius:
				var newNote = load(Global.pathFromCurSkin("Note.tscn")).instance()
				newNote.direction = direction
				newNote.notePosition = notePosition
				newNote.sustainLength = sustainLength
				UI.strums.get_child(direction).notes.add_child(newNote)
				
				notesToSpawn.erase(note)
			else:
				break

func presence_update():
	if not died:
		if music.stream:
			Discord.update_presence("Playing " + Global.songToLoad + " (" + Global.songDifficulty + ")", "Time Left: " + Global.seconds_to_string(music.stream.get_length() - (TimeManager.position / 1000.0)))
		else:
			Discord.update_presence("Starting " + Global.songToLoad + " (" + Global.songDifficulty + ")")
	else:
		Discord.update_presence("Died playing " + Global.songToLoad + " (" + Global.songDifficulty + ")", "Time Left: " + Global.seconds_to_string(music.stream.get_length() - (TimeManager.position / 1000.0)))
