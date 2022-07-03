extends Node2D

onready var banner = $Banner
onready var label = $Label

var background:StreamTexture

var targetY:int = 0
var curSelected:int = 0
var difficulties:Array = []

func changeDifficulty(change:int = 0):
	curSelected += change
	if curSelected < 0:
		curSelected = difficulties.size() - 1
	if curSelected > difficulties.size() - 1:
		curSelected = 0

func _process(delta):
	label.text = "< "+difficulties[curSelected]+" >"
	if Input.is_action_just_pressed("ui_left"):
		changeDifficulty(-1)
		
	if Input.is_action_just_pressed("ui_right"):
		changeDifficulty(1)
		
	positionUI(false, delta)

func positionUI(snap:bool = false, delta:float = 0.0):
	var yLerp:float = 360 + (targetY * 200)
	var scaleLerp:float = 1 - (float(targetY != 0)*0.2)
	var alphaLerp:float = 1 - (float(targetY != 0)*0.6)
	
	position.x = lerp(position.x, 1280, SubparMath.getLerpValue(0.15, delta))
	
	if snap:
		if label:
			label.modulate.a = int(targetY == 0)
		
		position.y = yLerp
		scale = Vector2(scaleLerp, scaleLerp)
		modulate.a = alphaLerp
	else:
		if label:
			label.modulate.a = lerp(label.modulate.a, int(targetY == 0), SubparMath.getLerpValue(0.15, delta))
		
		position.y = lerp(position.y, yLerp, SubparMath.getLerpValue(0.15, delta))
		scale = lerp(scale, Vector2(scaleLerp, scaleLerp), SubparMath.getLerpValue(0.15, delta))
		modulate.a = lerp(modulate.a, alphaLerp, SubparMath.getLerpValue(0.15, delta))
