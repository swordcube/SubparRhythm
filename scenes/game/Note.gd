class_name Note extends Node2D

@onready var sprite:Sprite2D = $Sprite
@onready var sustain:TextureRect = $Sustain
@onready var tail:Sprite2D = $Sustain/TailContainer/Tail

var data:ChartNote
var crochet:float = 0.0
var already_hit:bool = false
var missed:bool = false

var _og_length:float = 0.0
