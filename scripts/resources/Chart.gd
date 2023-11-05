class_name Chart extends Resource

@export var meta:ChartMeta = ChartMeta.new()
@export var bpm_changes:Array[ChartBPMChange] = []
@export var notes:Array[ChartNote] = []
@export var generated_by:String = "Subpar Rhythm Charter"

var _track:String

static func parse(track:String, difficulty:String):
	var file:String = "res://assets/game/songs/%s" % [track]
	
	## Friday Night Funkin' chart files
	var fnf_path:String = "%s/%s" % [file, difficulty+".json"]
	if FileAccess.file_exists(fnf_path):
		var fnfc:Chart = FNFVanillaV1Format.parse(fnf_path)
		fnfc._track = track
		return fnfc
	
	## StepMania chart files
	for sm_path in [
		"%s/%s.sm" % [file, track],
		"%s/%s.smc" % [file, track],
		"%s/stepmania.sm" % [file],
		"%s/stepmania.smc" % [file],
		"%s/%s.sm" % [file, difficulty],
		"%s/%s.smc" % [file, difficulty],
	]:
		if FileAccess.file_exists(sm_path):
			var smc:Chart = StepManiaFormat.parse(sm_path, difficulty)
			smc._track = track
			return smc
	
	## Subpar Rhythm chart files
	for subpar_path in [
		"%s/%s.tres" % [file, difficulty],
		"%s/%s.res" % [file, difficulty],
	]:
		if ResourceLoader.exists(subpar_path):
			var sc:Chart = load(subpar_path)
			sc._track = track
			return sc
	
	## Fallback chart
	var fc:Chart = Chart.new()
	fc._track = track
	return fc
