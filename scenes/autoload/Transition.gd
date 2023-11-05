extends CanvasLayer

signal pre_trans_in()
signal post_trans_in()

signal pre_trans_out()
signal post_trans_out()

@onready var overlay:ColorRect = $Overlay
@onready var anim_player:AnimationPlayer = $AnimationPlayer

func _ready():
	anim_player.animation_finished.connect(emit_post_signals)
	
func trans_in():
	pre_trans_in.emit()
	anim_player.play(&"in")
	
func trans_out():
	get_tree().paused = false
	pre_trans_out.emit()
	anim_player.play(&"out")

func emit_post_signals(anim_name:StringName):
	match anim_name:
		&"in": post_trans_in.emit()
		&"out": post_trans_out.emit()
