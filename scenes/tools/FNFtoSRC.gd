extends Node2D

func _ready():
	get_tree().paused = false

func _on_FileDialog_file_selected(path):
	var f = File.new()
	var error = f.open(path, File.READ)
	if error == OK:
		$Label2.text = "Status: Converting..."
		var rawText:String = f.get_as_text()
		var parsedJson = JSON.parse(rawText).result
		var songData = parsedJson.song
		
		var txtString:String = "bpm:"
		txtString += str(songData["bpm"]) + "\n"
		
		for section in songData["notes"]:
			for note in section["sectionNotes"]:
				txtString += "direction:" + str(note[1]) + "\n"
				txtString += "position:" + str(note[0]) + "\n"
				txtString += "sustaintime:" + str(note[2]) + "\n"
				
		f.close()
		
		var sf = File.new()
		var serr = sf.open(path.split(".json")[0]+".src", File.WRITE)
		if serr == OK:
			sf.store_string(txtString)
			sf.close()
			$Label2.text = "Status: Converted successfully!"
		else:
			$Label2.text = "Status: Error saving SRC file."
	else:
		$Label2.text = "Status: Error reading JSON."

func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		$FileDialog.popup_centered()
