extends Entity

class_name Planet

var is_hover = false

var children = []
var asteroids = []

var prefab_lava = preload('res://assets/PixelPlanets/LavaWorld/LavaWorld.tscn')
var prefab_iron = preload('res://assets/PixelPlanets/GasPlanet/GasPlanet.tscn')
var prefab_earth = preload('res://assets/PixelPlanets/LandMasses/LandMasses.tscn')
var prefab_ice = preload('res://assets/PixelPlanets/IceWorld/IceWorld.tscn')

func create():
	entity_type = Enums.entity_types.planet
	planet_size = Random.randf_range(1.0, 2.0)
	rotation_speed = Random.randf_range(-1, 1) * 10
	label = NameGenerator.get_name_planet()
	indestructible = true
	hitpoints_max = 250
	visible = false
	.create()
	
func ready():
	get_node("InfoUI").set_label(label)
	(get_node("PlanetArea/PlanetAreaCollision") as CollisionPolygon2D).polygon = self.planet_convex_hull
	
	Settings.connect("settings_changed", self, "update")
	
	var instance = null
	match planet_type:
		Enums.planet_types.lava:
			instance = prefab_lava.instance()
		Enums.planet_types.iron:
			instance = prefab_iron.instance()
		Enums.planet_types.earth:
			instance = prefab_earth.instance()
		Enums.planet_types.ice:
			instance = prefab_ice.instance()
			
	var radius = (planet_size * 200) / 2
	(instance as Control).rect_scale = Vector2(planet_size, planet_size)
	(instance as Control).set_position(Vector2(-radius, -radius))
	($PlanetCollision.shape as CircleShape2D).radius = radius

	add_child(instance)
	.ready()

func process(delta: float):
	if state == Enums.planet_states.produce or state == Enums.planet_states.convertion:
		process_time += delta
		
		if get_process_progress() > 1:
			if state == Enums.planet_states.produce:
				if process_target in Enums.ship_types.values():
					get_node('/root/GameScene').add_child(Instancer.ship(process_target, null, self))
			elif state == Enums.planet_states.convertion:
				var faction = Factions.get_faction(self.faction)
				var converted_amount = Consts.RESOURCE_CONVERTION_COST * Consts.RESOURCE_CONVERTION_RATIO
				match process_target:
					Enums.resource_types.titanium:
						faction.resources.titanium += converted_amount
					Enums.resource_types.astral_dust:
						faction.resources.astral_dust += converted_amount
			
			process_time = 0
			state = Enums.planet_states.idle
		
		GameState.emit_signal("update_ui")

	else:
		.process(delta)
	
func kill():
	faction = -1
	hitpoints = hitpoints_max
	
func _process(delta):
	if self.visible:
		.get_node("Sprite").rotation_degrees += rotation_speed * delta

func get_target_point():
	var angle = 2 * PI * randf()
	#var r = (.get_node("AreaPlanet").shape as CircleShape2D).radius * randf()
	
	#var x = r * cos(angle) + self.global_transform.origin.x
	#var y = r * sin(angle) + self.global_transform.origin.y
	
	return position #Vector2(x, y)

func _on_PlanetArea_body_entered(entity: Entity):
	if self.planet_system == entity.planet_system:
		children.append(entity)
		if entity.prop_type == Enums.prop_types.asteroid:
			asteroids.append(entity)
		entity.parent = self
		emit_signal("entity_changed")

func _on_PlanetArea_body_exited(entity: Entity):
	if self.planet_system == entity.planet_system:
		children.erase(entity)
		asteroids.append(entity)
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
				if ship.planet_system == self.planet_system and ship.has_method("set_target_id") and ship.faction == curr_selection.faction and ship.parent == curr_selection:
					ship.set_target_id(self.id)

func _on_hover_enter():
	is_hover = true
	update()

func _on_hover_leave():
	is_hover = false
	update()

func get_children_sorted_by_distance() -> Array:
	children.sort_custom(self, "sort_closest")
	return children
	
func sort_closest(a: Entity, b: Entity) -> bool:
	var dist_a = self.position.distance_squared_to(a.position)
	var dist_b = self.position.distance_squared_to(b.position)
	return dist_a < dist_b

func get_children_by_type(type: int, specific_type: String = 'entity_type') -> Array:
	var children_by_type = []
	for child in children:
		if child[specific_type] == type and (child.faction == faction or child.faction == -1):
			children_by_type.append(child)
	return children_by_type
