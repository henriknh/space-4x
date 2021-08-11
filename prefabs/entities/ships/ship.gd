extends Entity

class_name Ship

var parent: Entity setget set_parent
var enemy: Entity
signal parent_changed
signal ship_arrive
var is_over_drive = false

var ship_count: int = 1 setget _set_ship_count

onready var node_mesh: MeshInstance = $Mesh

func _ready():
	add_to_group('Persist')
	add_to_group('Ship')
	
	node_mesh.material_override = MaterialLibrary.get_material(corporation_id)

func set_parent(_parent: Entity):
	parent = _parent
	emit_signal("parent_changed")

func _set_ship_count(_ship_count):
	ship_count = _ship_count
	emit_signal("entity_changed")
