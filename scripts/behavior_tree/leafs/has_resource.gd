extends Task

class_name HasResource

onready var host: Entity = get_owner()
export(Enums.produce_types) var produce_type: int = 0
export(Enums.research_types) var research_type: int = 0

func _ready():
	if not host:
		breakpoint
	
func run():
	var corporation = host.get_corporation()
	
	if corporation:
		if produce_type != Enums.produce_types.NONE:
			if not Enums.produce_types_cost.has(produce_type):
				breakpoint
			elif corporation.resource_titanium >= Enums.produce_types_cost[produce_type]:
				return success()
		elif research_type != Enums.research_types.NONE:
			if not Enums.research_types_cost.has(research_type):
				breakpoint
			elif corporation.resource_dust >= Enums.research_types_cost[research_type]:
				return success()
		else:
			breakpoint # Neither produce_type or research_type set
	
	fail()
