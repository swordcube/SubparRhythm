class_name PauseMenu extends CanvasLayer

@onready var bg:ColorRect = $BG
@onready var paused_title:Label = $PausedTitle
@onready var song_name:Label = $SongName
@onready var options:Node2D = $Options

var cur_selected:int = 0

var _chart:Chart
var _can_select:bool = false

func _ready():
	get_tree().paused = true
	
	song_name.text = "%s [%s]" % [_chart.meta.title, _chart._difficulty]
	song_name.size.x = 0
	song_name.position.x = 1280
	
	var bg_tween:Tween = create_tween()
	bg_tween.set_ease(Tween.EASE_IN_OUT)
	bg_tween.set_trans(Tween.TRANS_EXPO)
	bg_tween.tween_property(bg, "modulate:a", 0.6, 0.75)
	
	var pause_title_tween:Tween = create_tween()
	pause_title_tween.set_ease(Tween.EASE_IN_OUT)
	pause_title_tween.set_trans(Tween.TRANS_EXPO)
	pause_title_tween.tween_property(paused_title, "position:x", 1006, 0.75)
	
	var song_name_tween:Tween = create_tween()
	song_name_tween.set_ease(Tween.EASE_IN_OUT)
	song_name_tween.set_trans(Tween.TRANS_EXPO)
	song_name_tween.tween_property(song_name, "position:x", 1190 - song_name.size.x, 0.75)
	
	for i in options.get_child_count():
		var opt:Label = options.get_child(i)
		opt.position.x = 1300.0
		opt.modulate.a = 0.5
		
		var opt_tween:Tween = create_tween()
		opt_tween.set_ease(Tween.EASE_IN_OUT)
		opt_tween.set_trans(Tween.TRANS_EXPO)
		opt_tween.tween_interval((i + 1) * 0.1)
		opt_tween.tween_property(opt, "position:x", 860, 0.75)
		
	var timer:SceneTreeTimer = get_tree().create_timer(0.3 * options.get_child_count())
	timer.timeout.connect(func(): _can_select = true)

func accept_pause_item():
	match cur_selected:
		0: # Resume
			_can_select = false
			
			var bg_tween:Tween = create_tween()
			bg_tween.set_ease(Tween.EASE_IN_OUT)
			bg_tween.set_trans(Tween.TRANS_EXPO)
			bg_tween.tween_property(bg, "modulate:a", 0.0, 0.75)
			
			var pause_title_tween:Tween = create_tween()
			pause_title_tween.set_ease(Tween.EASE_IN_OUT)
			pause_title_tween.set_trans(Tween.TRANS_EXPO)
			pause_title_tween.tween_property(paused_title, "position:x", 1300, 0.75)
			
			var song_name_tween:Tween = create_tween()
			song_name_tween.set_ease(Tween.EASE_IN_OUT)
			song_name_tween.set_trans(Tween.TRANS_EXPO)
			song_name_tween.tween_property(song_name, "position:x", 1280, 0.75)
			
			for i in options.get_child_count():
				var opt:Label = options.get_child(i)
				var opt_tween:Tween = create_tween()
				opt_tween.set_ease(Tween.EASE_IN_OUT)
				opt_tween.set_trans(Tween.TRANS_EXPO)
				opt_tween.tween_interval((i + 1) * 0.1)
				opt_tween.tween_property(opt, "position:x", 1300, 0.75)
			
			await get_tree().create_timer(0.3 * options.get_child_count()).timeout
			get_tree().paused = false
			queue_free()
			
		1: # Restart
			var game:Gameplay = load("res://scenes/Gameplay.tscn").instantiate()
			game.chart = _chart
			Tools.switch_scene_to_node(game)
			
		2: # Exit
			pass

func _unhandled_key_input(event:InputEvent):
	if not _can_select:
		return
	
	if Input.is_action_just_pressed("ui_up") or Input.is_action_just_pressed("ui_down"):
		var axis:int = int(Input.get_axis("ui_up", "ui_down"))
		cur_selected = wrapi(cur_selected + axis, 0, options.get_child_count())

	if Input.is_action_just_pressed("ui_accept"):
		await get_tree().create_timer(0.01).timeout
		accept_pause_item()

func _process(delta:float):
	if not _can_select:
		return
		
	for i in options.get_child_count():
		var opt:Label = options.get_child(i)
		opt.modulate.a = lerpf(opt.modulate.a, 1.0 if cur_selected == i else 0.5, delta * 15)
		opt.position.x = lerpf(opt.position.x, 820.0 if cur_selected == i else 860.0, delta * 15)
