extends Entity

class_name Planet

var planet_type: int = -1
var planet_size: float = 1.0
var planet_disabled_ships = 0
var planet_explorer_ships = 0
var hitpoints: int = 0
var planet_convex_hull = []

var is_hover = false

var ships = []
var asteroids = []

onready var node_info = $InfoUI
onready var node_collision: CollisionShape2D = $PlanetCollision
onready var node_planet_area = $PlanetArea
onready var node_planet_area_collision = $PlanetArea/PlanetAreaCollision

func create():
	entity_type = Enums.entity_types.planet
	planet_size = Random.randf_range(1.0, 2.0)
	hitpoints = Consts.PLANET_HITPOINTS
	visible = false
	.create()
	
func _ready():
	node_planet_area_collision.polygon = self.planet_convex_hull
	node_collision.shape = CircleShape2D.new()
	node_collision.shape.radius = planet_size * Consts.PLANET_SIZE_FACTOR

	._ready()

func process(delta: float):
	
	if state != Enums.planet_states.colonize:
		process_time += delta * planet_explorer_ships
		
		if get_process_progress() > 1:
			
			process_time = 0
			state = Enums.planet_states.idle
		
	if state == Enums.planet_states.produce or state == Enums.planet_states.convertion:
		process_time += delta
		
		if get_process_progress() > 1:
			if state == Enums.planet_states.produce:
				if process_target in Enums.ship_types.values():
					get_node('/root/GameScene').add_child(Instancer.ship(process_target, null, self))
			elif state == Enums.planet_states.convertion:
				var corporation = get_corporation()
				var converted_amount = Consts.RESOURCE_CONVERTION_COST * Consts.RESOURCE_CONVERTION_RATIO
				match process_target:
					Enums.resource_types.titanium:
						corporation.titanium += converted_amount
					Enums.resource_types.astral_dust:
						corporation.astral_dust += converted_amount
			
			process_time = 0
			state = Enums.planet_states.idle
		
		GameState.emit_signal("update_ui")

	else:
		.process(delta)

func _draw():
	if corporation_id <= 0:
		draw_circle(Vector2.ZERO, planet_size * Consts.PLANET_SIZE_FACTOR, Color(0.25,0.25,0.25,1))

	if corporation_id < 0:
		draw_circle(Vector2.ZERO, planet_size * Consts.PLANET_SIZE_FACTOR * get_process_progress(), Enums.corporation_colors[corporation_id])
	
	if corporation_id > 0:
		draw_circle(Vector2.ZERO, planet_size * Consts.PLANET_SIZE_FACTOR, Enums.corporation_colors[corporation_id])
	
		
func kill():
	self.corporation_id = 0
	self.hitpoints = Consts.PLANET_HITPOINTS
	update()

func is_dead() -> bool:
	return hitpoints <= 0
	
func _on_PlanetArea_body_entered(entity: Entity):
	if self.planet_system == entity.planet_system:
		match entity.entity_type:
			Enums.entity_types.prop:
				if entity.prop_type == Enums.prop_types.asteroid:
					asteroids.append(entity)
					asteroids.sort_custom(self, "sort_closest")
			Enums.entity_types.ship:
				ships.append(entity)
				ships.sort_custom(self, "sort_closest")
				if entity.has_method('set_parent'):
					entity.set_parent(self)
		emit_signal("entity_changed")

func _on_PlanetArea_body_exited(entity: Entity):
	if self.planet_system == entity.planet_system:
		if entity.entity_type == Enums.entity_types.ship:
			ships.erase(entity)
		if entity.entity_type == Enums.entity_types.prop and entity.prop_type == Enums.prop_types.asteroid:
			asteroids.erase(entity)
		emit_signal("entity_changed")
		
func _on_PlanetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		if (event as InputEventMouseButton).button_index == BUTTON_LEFT:
			if GameState.get_selection() == self:
				GameState.set_selection(null)
			else:
				GameState.set_selection(self)
		
		elif (event as InputEventMouseButton).button_index == BUTTON_RIGHT:
			var curr_selection = GameState.get_selection()
			for ship in get_tree().get_nodes_in_group('Ship'):
				if ship.planet_system == self.planet_system and ship.has_method("set_target_id") and ship.corporation_id == curr_selection.corporation_id and ship.parent == curr_selection:
					ship.set_target_id(self.id)

func _on_hover_enter():
	is_hover = true
	update()

func _on_hover_leave():
	is_hover = false
	update()
	
func sort_closest(a: Entity, b: Entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b

func save():
	var save = .save()
	
	save["planet_type"] = planet_type
	save["planet_size"] = planet_size
	save["planet_disabled_ships"] = planet_disabled_ships
	save["planet_explorer_ships"] = planet_explorer_ships
	save["hitpoints"] = hitpoints
	
	var i = 0
	for point in planet_convex_hull:
		save['planet_convex_hull_%d_x' % i] = point.x
		save['planet_convex_hull_%d_y' % i] = point.y
		i = i + 1
	
	return save
