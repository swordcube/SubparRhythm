class_name Conductor extends Node

signal beat_hit(beat:int)
signal step_hit(step:int)
signal measure_hit(measure:int)

var time:float = 0.0
var bpm:float = 100.0

var beatf:float = 0.0
var measuref:float = 0.0
var stepf:float = 0.0

var beati:int:
	get: return floori(beatf)
var measurei:float:
	get: return floori(measuref)
var stepi:float:
	get: return floori(stepf)
	
var crochet:float:
	get: return 60.0 / bpm
var step_crochet:float:
	get: return crochet / 4.0
	
var _last_time:float = 0.0

func _process(delta:float):
	var dt:float = time - _last_time
	
	var beat_delta:float = (bpm / 60.0) * dt
	beatf += beat_delta
	stepf += beat_delta * 4.0
	measuref += beat_delta / 4.0
	
	var last_beat:int = beati
	var last_step:int = stepi
	var last_measure:int = measurei
	
	if last_beat != beati:
		beat_hit.emit(beati)
		
	if last_step != stepi:
		step_hit.emit(stepi)
		
	if last_measure != measurei:
		measure_hit.emit(measurei)
	
	_last_time = time
