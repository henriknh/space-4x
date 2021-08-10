extends Task

class_name HasResearch

onready var host: Entity = get_owner()
export(Enums.research_types) var research: int = -1

func _ready():
	if not host:
		breakpoint
	
func run():
	var corporation = host.get_corporation()
	
	if corporation and corporation.has_research(research):
		success()
	else:
		fail()
