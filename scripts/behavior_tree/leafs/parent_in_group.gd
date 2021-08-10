extends Task

class_name ParentInGroup

onready var host: Miner = get_owner()
export(Array, String) var group_names

func _ready():
	if not host:
		breakpoint
	if group_names.size() == 0:
		breakpoint
	
func run():
	running()
	
	if host.parent and host.parent.entity:
		for group_name in group_names:
			if host.parent.entity.is_in_group(group_name):
				return success()
	
	fail()
