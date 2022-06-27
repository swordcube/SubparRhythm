extends Node

class_name Ranking

const judgements:Dictionary = {
	"marvelous": {
		"time": 22.5,
		"score": 300,
		"mod": 1
	},
	"perfect": {
		"time": 45,
		"score": 300,
		"mod": 0.95
	},
	"good": {
		"time": 90,
		"score": 200,
		"mod": 0.7
	},
	"bad": {
		"time": 135,
		"score": 100,
		"mod": 0.4
	},
	"trash": {
		"time": INF,
		"score": 50,
		"mod": 0,
		"health": -8.15
	}
}

const ranks:Dictionary = {
	100: "S+",
	90: "S",
	80: "A",
	70: "B",
	60: "C",
	50: "D",
	40: "E",
	30: "F"
};

static func judgeNote(strumTime:float):
	var noteDiff:float = abs(TimeManager.position - strumTime)
	var lastJudge:String = "no"
	
	for key in judgements.keys():
		if noteDiff <= judgements[key].time and lastJudge == "no":
			lastJudge = key
	
	if lastJudge == "no":
		lastJudge = judgements.keys()[len(judgements) - 1]
	
	return lastJudge
	
static func getRank(accuracy:float):
	if accuracy > 0:
		# biggest Haccuracy
		var bigHacc:int = 0;
		var leRank:String = ""
		
		for rank in ranks.keys():
			var minAccuracy = rank
			if minAccuracy <= accuracy and minAccuracy >= bigHacc:
				bigHacc = minAccuracy
				leRank = ranks[rank]
		
		return leRank
	
	return "?"
