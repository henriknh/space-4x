extends Entity

class_name Planet

onready var node_mesh: MeshInstance = $Mesh
	
func _ready():
	set_process_input(true)
	add_to_group('Persist')
	add_to_group('Planet')
	
	connect("entity_changed", self, "set_material")
	set_material()

func save():
	var save = .save()
	return save

func queue_free():
	health = 25
	self.corporation_id = 0

func set_material():
	node_mesh.set_surface_material(0, MaterialLibrary.get_material(corporation_id))
	
func on_research():
	print('on_research')
	
func on_produce_fighter():
	print('on_produce_fighter')
	
func on_produce_carrier():
	print('on_produce_carrier')
