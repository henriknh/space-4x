extends State

export var weapon: NodePath
export var parent_weapons: NodePath
export var on_no_target_state: NodePath

var _weapons: Array = []

func _ready():
	if not weapon and not parent_weapons:
		breakpoint
	if not on_no_target_state:
		breakpoint
	
	if weapon:
		_weapons.append(get_node(weapon) as Weapon)
	
	if parent_weapons:
		for _weapon in get_node(parent_weapons).get_children():
			_weapons.append(_weapon as Weapon)

func update(delta):
	if _weapons.size() > 0:
		for _weapon in _weapons:
			if not _weapon.update(host, delta):
				return on_no_target_state
