extends Node

var factions = {}

func create(faction: int) -> Faction:
	var ai = Faction.new(faction)
	factions[faction] = ai
	return ai

func get_faction(faction: int) -> Faction:
	if factions.has(faction):
		return factions[faction]
	else:
		return null
