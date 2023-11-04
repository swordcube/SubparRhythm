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
	
	var cur_bpm:float = chart.bpm_changes[0].new_bpm
	var sections:Array = Tools.value_from_dict(json, "notes")
	var beat:float = 0.0
	if sections != null:
		for section in sections:
			if section == null:
				continue
			
			beat += (cur_bpm / 60.0)
			var change_bpm:bool = Tools.value_from_dict(section, "changeBPM", false)
			var new_bpm:float = Tools.value_from_dict(section, "bpm", 0.0)
			
			if change_bpm and new_bpm > 0.0:
				cur_bpm = new_bpm
				var bc:ChartBPMChange = ChartBPMChange.new()
				bc.beat = beat
				bc.new_bpm = new_bpm
				chart.bpm_changes.append(bc)
			
			var notes:Array = Tools.value_from_dict(section, "sectionNotes")
			if notes != null:
				for note in notes:
					var c:ChartNote = ChartNote.new()
					c.time = note[0] * 0.001
					c.lane = int(note[1]) % 4
					c.length = note[2]
					c.type = 0 # for now :/
					chart.notes.append(c)
	
	chart.notes.sort_custom(func(a:ChartNote, b:ChartNote):
		return a.time < b.time
	)
	return chart
