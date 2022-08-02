extends CanvasLayer

onready var fpsText:Label = $Panel/FPS
onready var memoryText:Label = $Panel/Memory

func _ready():
	var timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "_update")
	timer.one_shot = false
	timer.start(0.75)
	_update()
	
func _update():
	fpsText.text = str(Engine.get_frames_per_second()) + " FPS"
	var mem = (Performance.get_monitor(Performance.MEMORY_STATIC)/100000)/10
	var memPeak = (Performance.get_monitor(Performance.MEMORY_STATIC_MAX)/100000)/10
	memoryText.text = str(stepify(mem, 0.01))+"mb / "+str(stepify(memPeak, 0.01))+"mb"
