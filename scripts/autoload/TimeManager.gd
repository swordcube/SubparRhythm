extends Node

var bpm:float = 100.0
var position:float = 0.0
var safeFrames:float = 15.0
var safeZoneOffset:float = (safeFrames / 60.0) * 1000.0

var timeBetweenBeats:float = ((60 / bpm) * 1000)
var timeBetweenSteps:float = timeBetweenBeats / 4

var curBeat:int = 0
var curStep:int = 0

var timeScale:Array = [4, 4]

# funny array of [position_in_song, bpm, step_change_is_at]
var bpmChanges:Array = []

signal beatHit
signal stepHit

func _process(_delta):
	var oldBeat = curBeat
	var oldStep = curStep

	var lastChange:Array = [0,0,0]
	
	for change in bpmChanges:
		if position >= change[0]:
			lastChange = change
			
			bpm = change[1]
			recalculateValues()
		else:
			break
	
	if len(lastChange) < 3:
		lastChange.append(0)
	
	curStep = lastChange[2] + floor((position - lastChange[0]) / timeBetweenSteps)
	curBeat = floor(curStep / 4)
	
	if curStep > 0 and curStep != oldStep and curStep > oldStep:
		emit_signal("stepHit")
	if curBeat > 0 and curBeat != oldBeat and curBeat > oldBeat:
		emit_signal("beatHit")

func recalculateValues():
	timeBetweenBeats = ((60 / bpm) * 1000)
	timeBetweenSteps = timeBetweenBeats / 4
	safeZoneOffset = ((safeFrames / 60.0) * 1000.0) * Global.songSpeed

func changeBPM(newBPM, changes = []):
	if len(changes) == 0:
		changes = [[0, newBPM, 0]]
	
	bpmChanges = changes
	bpm = newBPM
	recalculateValues()
