extends UIElements

onready var gameplay = $"../"

onready var healthBar:Node2D = $HealthBar
onready var strums:Node2D = $Strums

onready var accuracy:Label = $Accuracy
onready var combo:Label = $Combo

func _ready():
	for i in Global.songData.keyCount:
		var newStrum = load(Global.pathFromCurSkin("StrumNote.tscn")).instance()
		newStrum.direction = i
		newStrum.position.x += (Global.songData.keyCount * ((arrowSpacing / 2) * -1)) + (arrowSpacing / 2)
		newStrum.position.x += i * arrowSpacing
		strums.add_child(newStrum)
		
func _process(delta):
	if Input.is_action_just_pressed("ui_accept"):
		SceneManager.switchScene("gameplay/Gameplay")
		
	accuracy.text = str(stepify(gameplay.accuracy*100.0, 0.01))+"%"
	combo.text = str(gameplay.combo)
		
func playerDeath():
	$YouDied.visible = true
