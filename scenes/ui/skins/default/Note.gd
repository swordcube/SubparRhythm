extends Node2D

var direction:int = 0

var notePosition:float = 0.0

var sustainLength:float = 0.0

onready var animatedSprite:AnimatedSprite = $AnimatedSprite

func playAnim(anim:String):
	animatedSprite.play(anim)
