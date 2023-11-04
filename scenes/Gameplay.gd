extends Node2D

const VOLUME_MUTE_ICON:Texture2D = preload("res://assets/game/ui/volume_mute.png")
const VOLUME_MID_ICON:Texture2D = preload("res://assets/game/ui/volume_mid.png")
const VOLUME_FULL_ICON:Texture2D = preload("res://assets/game/ui/volume_full.png")

const RECEPTOR_STATIC:Texture = preload("res://assets/game/noteskins/default/static.png")
const RECEPTOR_PRESSED:Texture = preload("res://assets/game/noteskins/default/pressed.png")
const RECEPTOR_CONFIRM:Texture = preload("res://assets/game/noteskins/default/confirm.png")

var NOTE_OBJ:Note = load("res://scenes/game/Note.tscn").instantiate()

@onready var conductor:Conductor = $Conductor
@onready var music:AudioStreamPlayer = $Music

@onready var strum_line:Node2D = $StrumLine
@onready var note_group:Node2D = $NoteGroup

@onready var fps_card:Label = $FPSCard

@onready var volume_card:Label = $VolumeCard
@onready var volume_card_icon:Sprite2D = $VolumeCard/Icon

@onready var ram_card:Label = $RAMCard

@onready var song_card:Label = $SongCard
@onready var composer_card:Label = $SongCard/ComposerCard

var chart:Chart
var receptors:Array[Sprite2D] = []
var music_started:bool = false

var _pressed:Array[bool] = [false, false, false, false]
var _latest_note:int = 0

func _ready():
	song_card.position.x = 1330.0
	
	chart = Chart.parse("MC MENTAL @ HIS BEST", "Medium")
	music.stream = load(Paths.sound("music", "game/songs/%s" % [chart._track]))
	
	conductor.bpm = chart.bpm
	conductor.time = conductor.crochet * -5.0
	
	var timer:Timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(update_stat_cards)
	add_child(timer)
	timer.start(1.0)
	
	for r in strum_line.get_children():
		if r is Sprite2D:
			receptors.append(r)
	
	if not Settings.data.downscroll:
		strum_line.position.y = 100.0
	
	song_card.text = chart.meta.title
	composer_card.text = chart.meta.composer
	
	update_stat_cards()
	update_volume_card()
	
func _process(delta:float):
	conductor.time += minf(delta, 0.1) 
	if conductor.time >= 0.0 and not music_started:
		conductor.time = 0.0
		music_started = true
		music.play(-chart.meta.offset)
		show_song_card()
		print("Starting music...")
	
	note_group.position.y = 620.0 + (conductor.time * 1530.0)
	
func _physics_process(delta:float):
	if music_started and absf(conductor.time - (music.get_playback_position() + chart.meta.offset)) > 0.02:
		music.seek(conductor.time - chart.meta.offset)
	
	while _latest_note < chart.notes.size():
		var data:ChartNote = chart.notes[_latest_note]
		if data.time > conductor.time + 1.5:
			break
		
		# TODO: use pooling stuffs
		var receptor:Sprite2D = receptors[data.lane]
		var spawned:Note = NOTE_OBJ.duplicate()
		spawned.data = data.duplicate()
		spawned.data.time += Settings.data.note_offset * 0.001
		spawned.position = Vector2(receptor.position.x, spawned.data.time * (Settings.data.scroll_speed * -0.45))
		spawned.rotation = receptor.rotation
		note_group.add_child(spawned)
			
		_latest_note += 1
		
	var miss_radius:float = (0.3 / (Settings.data.scroll_speed * 0.001))
	for note in note_group.get_children():
		if note.data.time <= conductor.time - miss_radius:
			note.queue_free()
	
func _unhandled_key_input(event:InputEvent):
	event = event as InputEventKey
	
	if Input.is_action_just_pressed("volume_mute"):
		Settings.data.muted = not Settings.data.muted
		
		var master:int = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_mute(master, Settings.data.muted)
		
		update_volume_card()
		
	if Input.is_action_just_pressed("volume_up") or Input.is_action_just_pressed("volume_down"):
		var axis:float = Input.get_axis("volume_down", "volume_up")
		Settings.data.volume = clampf(snappedf(Settings.data.volume + (axis * 0.05), 0.05), 0.0, 1.0)
		
		var master:int = AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(master, linear_to_db(Settings.data.volume))
		
		update_volume_card()
		
	for i in Settings.data.keybinds_4k.size():
		var key:int = Settings.data.keybinds_4k[i]
		if event.keycode == key:
			if event.pressed:
				if not _pressed[i]:
					handle_note_input(i, true)
				_pressed[i] = true
			else:
				handle_note_input(i, false)
				_pressed[i] = false

func handle_note_input(lane:int, press:bool):
	if press:
		var possible_notes:Array[Node] = note_group.get_children().filter(func(n):
			return n.data.lane == lane and n.data.time < conductor.time + 0.122
		)
		var confirm:bool = possible_notes.size() > 0
		if confirm:
			possible_notes[0].queue_free()
		
		receptors[lane].texture = RECEPTOR_CONFIRM if confirm else RECEPTOR_PRESSED
	else:
		receptors[lane].texture = RECEPTOR_STATIC

func show_song_card():
	var biggest_size:float = song_card.size.x
	if song_card.size.x > composer_card.size.x:
		composer_card.size.x = song_card.size.x
	elif composer_card.size.x > song_card.size.x:
		biggest_size = composer_card.size.x
		song_card.size.x = composer_card.size.x
		
	var tween:Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CIRC)
	tween.tween_property(song_card, "position:x", 1280.0 - (biggest_size + 10.0), 0.5)
	tween.tween_interval(5.0)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(song_card, "position:x", 1330, 0.5)

func update_stat_cards():
	var m_fps:int = int(DisplayServer.screen_get_refresh_rate())
	if m_fps < 0: m_fps = 60
	
	var vsync:bool = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	var max_fps:int = m_fps if vsync else Engine.max_fps
	
	var cur_fps:int = Engine.get_frames_per_second()
	var cur_ram:int = OS.get_static_memory_usage() / 1048576
	
	var fps_style:StyleBoxFlat = fps_card.get_theme_stylebox("normal") as StyleBoxFlat
	if cur_fps < max_fps * 0.3: fps_style.border_color = Color("ff555f")
	elif cur_fps < max_fps * 0.5: fps_style.border_color = Color("ffd555")
	else: fps_style.border_color = Color("55ff80")
		
	var ram_style:StyleBoxFlat = ram_card.get_theme_stylebox("normal") as StyleBoxFlat
	ram_style.border_color = Color("55ff80")
	if cur_ram > 511: ram_style.border_color = Color("ffd555")
	if cur_ram > 1023: ram_style.border_color = Color("ff555f")
	
	fps_card.text = "%s / %s FPS" % [cur_fps, max_fps]
	ram_card.text = "%s / %s" % [String.humanize_size(OS.get_static_memory_usage()), String.humanize_size(OS.get_static_memory_peak_usage())]
	
	for card in [fps_card, ram_card]:
		card.size.x = 0.0
		
func update_volume_card():
	volume_card.text = "Muted" if Settings.data.muted else "%s%s" % [roundf(Settings.data.volume * 100), "%"]
	
	var vol_style:StyleBoxFlat = volume_card.get_theme_stylebox("normal") as StyleBoxFlat
	if Settings.data.muted or Settings.data.volume <= 0.0:
		vol_style.border_color = Color("ff555f")
		volume_card_icon.texture = VOLUME_MUTE_ICON
	elif Settings.data.volume <= 0.5: 
		vol_style.border_color = Color("ffd555")
		volume_card_icon.texture = VOLUME_MID_ICON
	else:
		vol_style.border_color = Color("55ff80")
		volume_card_icon.texture = VOLUME_FULL_ICON
