extends Node

func playSFX(sound:String):
	var node:AudioStreamPlayer = get_node("SFX/"+sound)
	node.play(0.0)
