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

func get_actions() -> Array:
	var research = Action.new().init(self, 'on_research', preload("res://assets/icons/react.png"))
	research.label = "Research"
	
	var produce_fighter = Action.new().init(self, 'on_produce_fighter', preload("res://assets/icons/ship.png"))
	produce_fighter.disabled = get_corporation().resources < Consts.SHIP_COST_FIGHTER
	produce_fighter.label = "Fighter"
	
	var produce_carrier = Action.new().init(self, 'on_produce_carrier', preload("res://assets/icons/ship.png"))
	produce_carrier.disabled = get_corporation().resources < Consts.SHIP_COST_CARRIER
	produce_carrier.label = "Carrier"
	
	return [
		research,
		produce_fighter,
		produce_carrier
	]
	
func on_research():
	print('on_research')
	
func on_produce_fighter():
	print('on_produce_fighter')
	
func on_produce_carrier():
	print('on_produce_carrier')
