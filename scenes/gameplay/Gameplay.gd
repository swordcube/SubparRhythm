extends BaseScene

var UI:Node2D

var notesToSpawn:Array = []

var died:bool = false

var accuracy:float = 0.0
var combo:int = 0

var totalHit:float = 0.0
var totalNotes:int = 0

onready var rating = $Rating

func _ready():
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
	
	Global.scrollSpeed /= Global.songSpeed
	
var startedSong:bool = false

onready var music = $Music
	
func _process(delta):
	TimeManager.position += (delta*1000.0)*Global.songSpeed
	# resync music if it goes off sync
	if not died:
		if TimeManager.position >= (music.get_playback_position()*1000.0) + 30:
			music.seek(TimeManager.position/1000.0)
		
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
			
			if TimeManager.position > notePosition - (300/(Global.scrollSpeed/1000.0))*Global.songSpeed:
				var newNote = load(Global.pathFromCurSkin("Note.tscn")).instance()
				newNote.direction = direction
				newNote.notePosition = notePosition
				newNote.sustainLength = sustainLength
				UI.strums.get_child(direction).notes.add_child(newNote)
				
				notesToSpawn.erase(note)
			else:
				break
