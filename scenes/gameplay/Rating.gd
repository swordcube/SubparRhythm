extends Sprite

onready var animPlayer = $AnimationPlayer

func _ready():
	modulate.a = 0

func bop():
	animPlayer.seek(0.0)
	animPlayer.play("bop")
