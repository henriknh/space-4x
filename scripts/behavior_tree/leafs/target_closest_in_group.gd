extends Task

class_name TargetClosestInGroup

onready var host: Entity = get_owner()
onready var states: Node = host.get_node("States")
export(Array, String) var group_names
export(bool) var allow_neutral = false

func _ready():
	if group_names.size() == 0:
		breakpoint

func run():
	running()
	
	var entities = []
	
	for group_name in group_names:
		entities.append_array(get_tree().get_nodes_in_group(group_name))
	
	var closest = null
	var dist = INF
	
	for entity in entities:
		var valid_target = entity.corporation_id == host.corporation_id
		if allow_neutral:
			valid_target = valid_target or entity.corporation_id == 0
		var _dist = host.global_transform.origin.distance_to(entity.global_transform.origin)
		if valid_target and _dist < dist:
			dist = _dist
			closest = entity
	
	if closest:
		host.target = closest
		success()
	else:
		fail()
