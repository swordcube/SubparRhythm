extends Node

func switchScene(scene:String, trans:bool = true):
	if trans:
		get_tree().paused = true
		Transition.playIn()
		
		yield(get_tree().create_timer(Transition.anim.get_animation("in").length), "timeout")
		
		get_tree().change_scene("res://scenes/" + scene + ".tscn")
		Transition.playOut()
		
		yield(get_tree().create_timer(Transition.anim.get_animation("out").length), "timeout")
		
		get_tree().paused = false
	else:
		get_tree().change_scene("res://scenes/" + scene + ".tscn")
