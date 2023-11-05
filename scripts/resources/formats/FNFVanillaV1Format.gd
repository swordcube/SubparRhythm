class_name FNFVanillaV1Parser extends Node

static func parse(file_path:String):
	var json:Dictionary = JSON.parse_string(FileAccess.open(file_path, FileAccess.READ).get_as_text())
	if json.has("song") and json.song != null and json.song is Dictionary:
		json = json.song
	
	var chart:Chart = Chart.new()
	
	var bpmc:ChartBPMChange = ChartBPMChange.new()
	bpmc.new_bpm = float(Tools.value_from_dict(json, "bpm", 100.0))
	chart.bpm_changes.append(bpmc)
	
	chart.meta.title = Tools.value_from_dict(json, "song", "???") 
	chart.meta.composer = Tools.value_from_dict(json, "composer", "???")
	chart.meta.credit = Tools.value_from_dict(json, "credit", "???")
	chart.meta.offset = Tools.value_from_dict(json, "offset", 0.0)
	
	var cur_change = chart.bpm_changes[0]
	var cur_bpm:float = cur_change.new_bpm
	var sections:Array = Tools.value_from_dict(json, "notes")
	var beat:float = 0.0
	var time:float = 0.0
	if sections != null:
		for section in sections:
			if section == null:
				continue
			
			var change_bpm:bool = Tools.value_from_dict(section, "changeBPM", false)
			var new_bpm:float = Tools.value_from_dict(section, "bpm", 0.0)
			
			if change_bpm and new_bpm > 0.0:
				cur_bpm = new_bpm
				var bc:ChartBPMChange = ChartBPMChange.new()
				bc.beat = beat
				bc.time = time
				bc.new_bpm = new_bpm
				cur_change = bc
				chart.bpm_changes.append(bc)
			
			var notes:Array = Tools.value_from_dict(section, "sectionNotes")
			if notes != null:
				for note in notes:
					var c:ChartNote = ChartNote.new()
					c.time = note[0] * 0.001
					c.lane = int(note[1]) % 4
					c.length = note[2]
					c.type = 0 # for now :/
					c.last_change = cur_change
					chart.notes.append(c)
				
			var beat_length:float = Tools.value_from_dict(section, "lengthInSteps", 16) * 0.25
			if section.has("sectionBeats"): # PSYCH ENGIN-
				beat_length = Tools.value_from_dict(section, "sectionBeats", 4)
			beat += beat_length
			time += (60.0 / cur_bpm) * beat_length
	
	chart.notes.sort_custom(func(a:ChartNote, b:ChartNote):
		return a.time < b.time
	)
	return chart
