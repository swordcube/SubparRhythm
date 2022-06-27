extends Node2D

onready var animatedSprite:AnimatedSprite = $AnimatedSprite
onready var notes:Node2D = $Notes

onready var gameplay = $"../../../"
onready var UI = $"../../"

var direction:int = 0
var dontHit:bool = false

func sortNotes(a, b):
	return a.notePosition < b.notePosition

func playAnim(anim:String):
	animatedSprite.play(anim)
	
var dumbBotplayTimerFuck:float = 0.0
	
func _process(delta):
	dumbBotplayTimerFuck += delta
	if Input.is_action_just_pressed("bind_" + str(direction)):
		playAnim("press")
		
	if Global.botPlay and dumbBotplayTimerFuck >= 0.03 or Input.is_action_just_released("bind_" + str(direction)):
		playAnim("static")
		
	var possibleNotes:Array = []
	for note in notes.get_children():
		note.position.y = 0.45 * (TimeManager.position - note.notePosition) * (Global.scrollSpeed / 1000.0)
		if (Global.botPlay and TimeManager.position >= note.notePosition) or (not Global.botPlay and TimeManager.position >= note.notePosition - TimeManager.safeZoneOffset):
			possibleNotes.append(note)
			
	possibleNotes.sort_custom(self, "sortNotes")
		
	dontHit = false
	for note in possibleNotes:
		if not dontHit:
			if Global.botPlay or Input.is_action_just_pressed("bind_" + str(direction)):
				possibleNotes.erase(note)
				notes.remove_child(note)
				note.queue_free()
				
				# remove stacked notes
				for coolNote in possibleNotes:
					if ((coolNote.notePosition - note.notePosition) < 2) and coolNote.direction == note.direction:
						notes.remove_child(coolNote)
						note.queue_free()
				
				UI.healthBar.progressBar.value += 1.5
				UI.healthBar.healthLossMult = 1
				
				var rating:String = Ranking.judgeNote(note.notePosition)
				gameplay.rating.texture = load(Global.imageFromCurSkin(rating))
				gameplay.rating.bop()
				
				gameplay.combo += 1
				gameplay.totalHit += Ranking.judgements[rating].mod
				gameplay.totalNotes += 1
				
				if "health" in Ranking.judgements[rating]:
					UI.healthBar.progressBar.value += Ranking.judgements[rating].health
				
				checkForDeath()
				
				dumbBotplayTimerFuck = 0.0
				playAnim("confirm")
			
				dontHit = true
				
		if TimeManager.position >= note.notePosition + TimeManager.safeZoneOffset:
			notes.remove_child(note)
			note.queue_free()
			
			# you lose more health with the more notes you miss
			# gets reset when you hit a note
			UI.healthBar.progressBar.value -= (3.5*UI.healthBar.healthLossMult)
			UI.healthBar.healthLossMult *= 1.2
			
			gameplay.combo = 0
			gameplay.totalNotes += 1
			
			checkForDeath()
			
func checkForDeath():
	if UI.healthBar.progressBar.value == 0 and not gameplay.died:
		gameplay.died = true
		gameplay.get_node("Music").stop()
		UI.playerDeath()
