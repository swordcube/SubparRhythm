class_name Gameplay extends Node2D

const VOLUME_MUTE_ICON:Texture2D = preload("res://assets/game/ui/volume_mute.png")
const VOLUME_MID_ICON:Texture2D = preload("res://assets/game/ui/volume_mid.png")
const VOLUME_FULL_ICON:Texture2D = preload("res://assets/game/ui/volume_full.png")

const RECEPTOR_STATIC:Texture = preload("res://assets/game/noteskins/default/static.png")
const RECEPTOR_PRESSED:Texture = preload("res://assets/game/noteskins/default/pressed.png")
const RECEPTOR_CONFIRM:Texture = preload("res://assets/game/noteskins/default/confirm.png")

const PAUSE_MENU:PackedScene = preload("res://scenes/game/PauseMenu.tscn")

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

@onready var rating_card:Label = $RatingCard
@onready var combo_card:Label = $ComboCard
@onready var combo_breaks_card:Label = $ComboBreaksCard

@onready var misses_card:Label = $MissesCard
@onready var accuracy_card:Label = $AccuracyCard
@onready var average_ms_card:Label = $AverageMSCard

const QUANT_VALUES:Dictionary = {
	4: Color8(255, 56, 112),
	8: Color8(0, 200, 255),
	12: Color8(192, 66, 255),
	16: Color8(0, 255, 123),
	20: Color8(196, 196, 196),
	24: Color8(255, 150, 234),
	32: Color8(255, 255, 82),
	48: Color8(170, 0, 255),
	64: Color8(0, 255, 255),
	192: Color8(196, 196, 196)
}

var chart:Chart
var receptors:Array[Sprite2D] = []
var music_started:bool = false
var combo_breaks:int = 0
var misses:int = 0

var ratings:Dictionary = {
	"Miss": {"ms": INF, "acc": 0.0, "color": Color("ff555f")},
	"Horrible": {"ms": 112.0, "acc": 0.0, "color": Color("ff555f")},
	"Bad": {"ms": 85.0, "acc": 0.3, "color": Color("ffd555")},
	"Great": {"ms": 62.0, "acc": 0.7, "color": Color("55ff80")},
	"Cool": {"ms": 45.0, "acc": 1.0, "color": Color("558aff")},
	"Nice": {"ms": 25.0, "acc": 1.0, "color": Color("af55ff")},
}
var rating_tween:Tween
var combo:int = 0
var total_notes_hit:int = 0

var note_spawn_thread:Thread
var can_spawn_notes:bool = true

var accuracy:float:
	get:
		if _accuracy_total_hit == 0.0 and (total_notes_hit + misses) == 0:
			return 0.0 
		return _accuracy_total_hit / (total_notes_hit + misses)
	
var average_ms:float:
	get:
		if total_notes_hit == 0:
			return 0.0
		
		var added_up_ms:float = 0.0
		for ms in _ms_list:
			added_up_ms += absf(ms)
		
		return added_up_ms / total_notes_hit

var _pressed:Array[bool] = [false, false, false, false]
var _latest_note:int = 0
var _ms_list:Array[float] = []

var _accuracy_total_hit:float = 0.0
var _latest_bpm_change:int = 0

func _ready():
	if not is_instance_valid(chart):
		chart = Chart.parse("Boiling Point", "hard")
	
	# Sort the notes
	chart.notes.sort_custom(func(a:ChartNote, b:ChartNote):
		return a.time < b.time
	)
	# Remove notes that are on top of each-other
	var i:int = 0
	var _last_time:float = -10
	var _notes:Array[ChartNote] = []
	for dir in 4:
		_last_time = -10
		for note in chart.notes:
			if note.lane != dir:
				continue
			if absf(_last_time - note.time) > 0.002:
				_notes.append(note)
				i += 1
			_last_time = note.time
	
	# Sort the notes (again, just in case)
	_notes.sort_custom(func(a:ChartNote, b:ChartNote):
		return a.time < b.time
	)
	chart.notes = _notes
	
	music.stream = load(Paths.sound("music", "game/songs/%s" % [chart._track]))
	
	conductor.bpm = chart.bpm_changes[0].new_bpm
	conductor.time = conductor.crochet * -5.0
	
	var timer:Timer = Timer.new()
	timer.one_shot = false
	timer.timeout.connect(update_stat_cards)
	timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(timer)
	timer.start(1.0)
	
	for r in strum_line.get_children():
		if r is Sprite2D:
			receptors.append(r)
	
	if not Settings.data.downscroll:
		strum_line.position.y = 100.0
	
	song_card.text = chart.meta.title
	composer_card.text = chart.meta.composer
	song_card.position.x = 1330.0
	
	note_spawn_thread = Thread.new()
	note_spawn_thread.start(func():
		while _latest_note < chart.notes.size():
			if not can_spawn_notes:
				break
			
			var data:ChartNote = chart.notes[_latest_note]
			if data.time > conductor.time + (1.5 / (Settings.data.scroll_speed * 0.001)):
				continue
			
			# TODO: use pooling stuffs
			var receptor:Sprite2D = receptors[data.lane]
			var spawned:Note = NOTE_OBJ.duplicate()
			spawned.data = data.duplicate()
			spawned.data.time += Settings.data.note_offset * 0.001
			spawned.position = Vector2(-INF, -INF)
			if spawned.data.length <= 0.05:
				spawned.data.length = 0.0
			spawned._og_length = spawned.data.length
			
			spawned.get_node("Sprite").rotation = receptor.rotation
			spawned.crochet = conductor.crochet
			
			var sustain:TextureRect = spawned.get_node("Sustain")
			sustain.visible = spawned.data.length > 0.0
			sustain.scale.y *= -1.0 if Settings.data.downscroll else 1.0
			
			var quant_array:Array = QUANT_VALUES.keys()
			
			var new_time:float = data.time - data.last_change.time
			var beat_time:float = 60.0 / data.last_change.new_bpm
			var measure_time:float = beat_time * 4.0
			var smallest_deviation:float = measure_time / quant_array[quant_array.size() - 1]
			
			for quant in quant_array.size():
				var quant_time:float = measure_time / quant_array[quant]
				if fmod(new_time + smallest_deviation, quant_time) < smallest_deviation * 2.0:
					spawned.modulate = QUANT_VALUES[quant_array[quant]]
					break
			
			_latest_note += 1
			note_group.call_deferred("add_child", spawned)
	)
	
	update_stat_cards()
	update_volume_card()
	update_combo_card()
	
func _process(delta:float):
	conductor.time += minf(delta, 0.1) 
	
	if conductor.time >= 0.0 and not music_started:
		conductor.time = 0.0
		music_started = true
		music.play(-chart.meta.offset)
		show_song_card()
		print("Starting music...")
	
	var note_speed:float = Settings.data.scroll_speed * 0.001
	var miss_radius:float = (0.3 / note_speed)
	
	for note in note_group.get_children():
		note = note as Note
		var receptor:Sprite2D = receptors[note.data.lane]
		note.position.x = receptor.position.x
		note.position.y = receptor.position.y - (0.45 * (conductor.time - note.data.time) * Settings.data.scroll_speed * (-1.0 if Settings.data.downscroll else 1.0))
		
		var sustain_size:float = ((note.data.length * 0.45 * note_speed) * 1000.0) / absf(note.sustain.scale.y)
		note.sustain.size.y = sustain_size
		note.tail.position.y = sustain_size + (note.tail.texture.get_height() * 0.5)
		
		if note.already_hit and note._og_length > 0.0:
			note.data.length -= delta
			if note.data.length <= -note.crochet:
				note.queue_free()
			
			if not _pressed[note.data.lane] and note.data.length > 0.05:
				note.data.length = note._og_length
				note.already_hit = false
				note.missed = true
				break_combo()
			
			note.sustain.self_modulate.a = 1.0 if (note.data.length > 0.01) else 0.0
			note.global_position.y = receptor.global_position.y
		
		if not note.missed and not note.already_hit and note.data.time <= conductor.time - miss_radius:
			note.missed = true
			break_combo()
			
		if note.missed and not note.already_hit and note.data.time <= conductor.time - ((0.3 + (note._og_length * 4.3)) / note_speed):
			miss_note(note, false)

func break_combo():
	if combo > 0:
		combo_breaks += 1
		combo = -1
	else:
		combo -= 1
	misses += 1
	show_rating_card(-INF, true)
	update_combo_card()

func miss_note(note:Note, _break_combo:bool = true):
	if _break_combo:
		break_combo()

	note.queue_free()
	
func _physics_process(delta:float):
	if music_started and absf(conductor.time - (music.get_playback_position() + chart.meta.offset)) > 0.03:
		music.seek(conductor.time - chart.meta.offset)
		
	while _latest_bpm_change < chart.bpm_changes.size():
		var data:ChartBPMChange = chart.bpm_changes[_latest_bpm_change]
		if data.beat > conductor.beatf:
			break
		
		conductor.bpm = data.new_bpm
		_latest_bpm_change += 1
	
func _unhandled_key_input(event:InputEvent):
	event = event as InputEventKey
	
	if OS.is_debug_build() and event.keycode == KEY_F4:
		conductor.time += 4.0
	
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
				
	if Input.is_action_just_pressed("pause"):
		var pause_menu:PauseMenu = PAUSE_MENU.instantiate() as PauseMenu
		pause_menu._chart = chart
		add_child(pause_menu)

func handle_note_input(lane:int, press:bool):
	if press:
		var possible_notes:Array[Node] = note_group.get_children().filter(func(n):
			return n.data.lane == lane and n.data.time < conductor.time + 0.182 \
				and not n.already_hit and not n.missed
		)
		var confirm:bool = possible_notes.size() > 0
		var note:Note = (possible_notes[0] as Note) if confirm else null
		if confirm and not note.already_hit and not note.missed:
			note.sprite.visible = false
			note.already_hit = true
			
			var note_ms:float = (conductor.time - note.data.time) * 1000.0
			if combo < 0: combo = 0
			combo += 1
			
			var rating:Dictionary = show_rating_card(note_ms)
			_accuracy_total_hit += rating.acc
			total_notes_hit += 1
			_ms_list.append(note_ms)
			
			update_combo_card()
			
			if note.data.length < 0.05:
				note.queue_free()
			else:
				note.data.length -= note_ms * 0.001
		
		receptors[lane].texture = RECEPTOR_CONFIRM if confirm else RECEPTOR_PRESSED
	else:
		receptors[lane].texture = RECEPTOR_STATIC

func rating_from_ms(ms:float, miss:bool = false):
	var cur_rating:String = "Horrible"
	for name in ratings.keys():
		var data:Dictionary = ratings[name]
		if data.ms == INF and not miss:
			continue
		if absf(ms) <= data.ms:
			cur_rating = name
	return cur_rating

func show_rating_card(note_ms:float, miss:bool = false):
	if is_instance_valid(rating_tween):
		rating_tween.stop()
	
	var cur_rating:String = rating_from_ms(note_ms, miss)
	rating_card.text = "%s (%.3f%s)" % [cur_rating, note_ms, "ms"] if cur_rating != "Miss" else "Combo Lost (%s%s)" % [-combo, "x"]
	rating_card.size.x = 0
	rating_card.position.x = 640 - (rating_card.size.x * 0.5)
	rating_card.modulate.a = 1.0
	rating_card.scale = Vector2(1.05, 1.05)
	rating_card.pivot_offset = rating_card.size * 0.5
	
	var rating_style:StyleBoxFlat = rating_card.get_theme_stylebox("normal") as StyleBoxFlat
	rating_style.border_color = ratings[cur_rating].color
	
	rating_tween = create_tween()
	rating_tween.set_ease(Tween.EASE_IN)
	rating_tween.set_trans(Tween.TRANS_CIRC)
	rating_tween.tween_property(rating_card, "scale", Vector2.ONE, 0.05)
	rating_tween.tween_interval(0.5)
	rating_tween.tween_property(rating_card, "modulate:a", 0.0, 0.5)

	return ratings[cur_rating]

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
	var max_fps:int = m_fps if vsync or Engine.max_fps == 0 else Engine.max_fps
	
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
	
	fps_card.text = "%s%s FPS" % [cur_fps, " / "+str(max_fps) if max_fps != 0 else ""]
	ram_card.text = "%s / %s" % [String.humanize_size(OS.get_static_memory_usage()), String.humanize_size(OS.get_static_memory_peak_usage())]
	
	for card in [fps_card, ram_card]:
		card.size.x = 0.0
		
func update_volume_card():
	volume_card.text = "Muted" if Settings.data.muted else "%s%s" % [roundf(Settings.data.volume * 100), "%"]
	volume_card.size.x = 0
	
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
		
func update_combo_card():
	var display_combo:int = 0 if combo < 0 else combo
	
	combo_card.text = "%s%s Combo" % [display_combo, "x"]
	combo_card.size.x = 0
	
	var combo_style:StyleBoxFlat = combo_card.get_theme_stylebox("normal") as StyleBoxFlat	
	combo_style.border_color = Color("ff555f")
	if display_combo > 19: combo_style.border_color = Color("55ff80")
	if display_combo > 49: combo_style.border_color = Color("558aff")
	if display_combo > 149: combo_style.border_color = Color("af55ff")
	
	combo_breaks_card.text = "%s Combo Breaks" % [combo_breaks]
	combo_breaks_card.size.x = 0
	
	var cb_style:StyleBoxFlat = combo_breaks_card.get_theme_stylebox("normal") as StyleBoxFlat	
	cb_style.border_color = Color("ff555f")
	if combo_breaks == 0: cb_style.border_color = Color("af55ff")
	if combo_breaks > 0 and combo_breaks < 15: cb_style.border_color = Color("558aff")
	if combo_breaks > 4 and combo_breaks < 15: cb_style.border_color = Color("ffd555")
	
	misses_card.text = "%s Misses" % [misses]
	misses_card.size.x = 0
	
	var miss_style:StyleBoxFlat = misses_card.get_theme_stylebox("normal") as StyleBoxFlat	
	miss_style.border_color = Color("ff555f")
	if misses == 0: miss_style.border_color = Color("af55ff")
	if misses > 0 and misses < 35: miss_style.border_color = Color("558aff")
	if misses > 24 and misses < 35: miss_style.border_color = Color("ffd555")
	
	accuracy_card.text = "%.2f%s Accuracy" % [accuracy * 100.0, "%"]
	accuracy_card.size.x = 0
	
	var acc_style:StyleBoxFlat = accuracy_card.get_theme_stylebox("normal") as StyleBoxFlat	
	acc_style.border_color = Color("ff555f")
	if accuracy >= 0.3: acc_style.border_color = Color("55ff80")
	if accuracy >= 0.5: acc_style.border_color = Color("ffd555")
	if accuracy >= 0.7: acc_style.border_color = Color("558aff")
	if accuracy >= 0.9: acc_style.border_color = Color("af55ff")
	
	average_ms_card.text = "%.2f%s [Average]" % [average_ms, "ms"]
	average_ms_card.size.x = 0
	
	var avg_ms_style:StyleBoxFlat = average_ms_card.get_theme_stylebox("normal") as StyleBoxFlat	
	avg_ms_style.border_color = ratings[rating_from_ms(average_ms)].color

func _exit_tree():
	can_spawn_notes = false
	note_spawn_thread.wait_to_finish()
