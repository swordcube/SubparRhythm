class_name StepManiaFormat extends Node

static func parse(file_path:String, difficulty:String):
	var sm_map:PackedStringArray = FileAccess.open(file_path, FileAccess.READ).get_as_text().strip_edges().split("\n")
	
	var chart:Chart = Chart.new()
	chart.bpm = float(_get_map_var(sm_map, "BPMS").split("=")[1])
	chart.meta.title = _get_map_var(sm_map, "TITLE")
	chart.meta.composer = _get_map_var(sm_map, "ARTIST")
	chart.meta.credit = _get_map_var(sm_map, "CREDIT")
	chart.meta.offset = float(_get_map_var(sm_map, "OFFSET"))
	
	var notes:Dictionary = _get_map_notes(sm_map, chart.bpm, difficulty)
	for i in notes.size():
		if not notes.has(i) or notes[i] == null:
			continue
			
		for n in notes[i]:
			var c_note:ChartNote = ChartNote.new()
			c_note.time = n[0]
			c_note.lane = n[1]
			c_note.length = n[2]
			c_note.type = n[3]
			chart.notes.append(c_note)
	
	return chart

static func _get_map_var(map:PackedStringArray, map_var:String):
	for line in map:
		var var_prefix:String = '#'+map_var
		if not line.begins_with(var_prefix):
			continue
		
		var ret_var:String = line.split(var_prefix+":")[1].strip_edges()
		if ret_var.ends_with(";"):
			ret_var = ret_var.substr(0, ret_var.length() - 1)
			
		return ret_var
	return null
	
static func _find_sustain_length(measure:PackedStringArray, start_sustain:Array[int]):
	var steps:int = 0
	for i in range(start_sustain[0], measure.size()):
		if measure[i].split('')[start_sustain[1]] == '3':
			break
		steps += 1
	return steps

static func _get_map_notes(map:PackedStringArray, bpm:float, difficulty:String):
	var crochet:float = 60.0 / bpm
	var step_crochet:float = crochet / 4.0
	var measure_crochet:float = crochet * 4.0
	
	var return_map:Dictionary = {}
	var note_measures:Dictionary = {}
	
	# Get the line measures actually start
	var gotten_diff:String = ""
	var notes_line:int = 0
	for l in map.size():
		if map[l].begins_with("#NOTES:"):
			for i in range(l, map.size()):
				if map[i].strip_edges().begins_with(difficulty): # we got a difficulty!!
					gotten_diff = difficulty
				
				if gotten_diff == difficulty and map[i].length() == 4: # STARTED NOTES!!
					notes_line = i
					break
			break
	
	var measure:int = 0
	for l in range(notes_line, map.size()):
		var note_line:String = map[l].strip_edges()
		if note_line.length() <= 0 or note_line == ';':
			continue
		if note_line.begins_with(","): # new measure
			measure += 1
		else: # Push notes to measure
			var last_measure_data:PackedStringArray = note_measures[measure] if note_measures.has(measure) and note_measures[measure] != null else []
			last_measure_data.append(note_line)
			note_measures[measure] = last_measure_data
	
	for i in note_measures.size():
		if not note_measures.has(i) or note_measures[i] == null:
			continue
	
		var measure_array:PackedStringArray = note_measures[i]
		var measure_time:float = measure_crochet * i
		var sec_array:Array = return_map[i] if return_map.has(i) and return_map[i] != null else []

		var beats_per_line:float = 4.0 / measure_array.size()
		var steps_per_line:float = 16.0 / measure_array.size()

		for l in measure_array.size(): # Lines
			var note_time:float = measure_time + (step_crochet * l * steps_per_line)
			var line:PackedStringArray = measure_array[l].split('')
			
			for lane in line.size(): # Notes
				match str(line[lane]):
					"1": # Normal note
						sec_array.append([note_time, lane, 0.0, 0])
					"2": # Hold head
						var length_steps:int = _find_sustain_length(measure_array, [l, lane])
						sec_array.append([note_time, lane, step_crochet * steps_per_line * length_steps, 0])
					"3": # Hold/Roll tail
						pass
					"4": # Roll head
						pass
					"M": # Mine
						sec_array.append([note_time, lane, 0.0, 1])
					_: # No/invalid note
						pass
				
		return_map[i] = sec_array
		
	return return_map
