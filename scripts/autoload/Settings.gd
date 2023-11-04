extends Node

const SAVE_FILE_PATH:String = "user://subpar_settings.cfg"

var data:Dictionary = {
	"downscroll": true,
	"hitsound": "None",
	
	"note_offset": 0.0,
	"scroll_speed": 3400.0,
	"lane_underlay_opacity": 0.5,
	
	"volume": 1.0,
	"muted": false,
	
	"keybinds_4k": [KEY_D, KEY_F, KEY_J, KEY_K]
}

var _cfg:ConfigFile

func _ready():
	const SEP:String = "---------------------------------------"
	Input.use_accumulated_input = false
	
	print("Initializing settings...")
	_cfg = ConfigFile.new()
	
	if FileAccess.file_exists(SAVE_FILE_PATH):
		print("Save data exists - Loading save...\n%s" % [SEP])
		_cfg.load(SAVE_FILE_PATH)
		
		var flush_new:bool = false
		for key in data.keys():
			var cfg_val:Variant = _cfg.get_value("main", key, null)
			if cfg_val == null:
				flush_new = true
				print("%s doesn't exist in save! Putting it there..." % [key])
				_cfg.set_value("main", key, data[key])
			else:
				print("%s exists in save!" % [key])
				data[key] = cfg_val
				
		if flush_new: _cfg.save(SAVE_FILE_PATH)
	else:
		print("Save data doesn't exist - Creating new save...")
		
		for key in data.keys():
			_cfg.set_value("main", key, data[key])
		
		_cfg.save(SAVE_FILE_PATH)
	
	apply()
	print("%s\nSettings successfully initialized!" % [SEP])

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Game closed, goodbye :3")
		
		for key in data.keys():
			_cfg.set_value("main", key, data[key])
		
		_cfg.save(SAVE_FILE_PATH)

func apply():
	var master:int = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master, linear_to_db(data.volume))
	AudioServer.set_bus_mute(master, data.muted)

func _unhandled_key_input(event:InputEvent):
	event = event as InputEventKey
	if Input.is_action_pressed("fullscreen"):
		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
