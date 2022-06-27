extends CanvasLayer

onready var anim:AnimationPlayer = $AnimationPlayer

func playIn():
	anim.play("in")
	
func playOut():
	anim.play("out")
