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
	planet_size = WorldGenerator.rng.randf_range(1.0, 2.0)
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
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
	if state == Enums.planet_states.produce:
		process_time += delta
		
		if get_process_progress() > 1:
			process_time = 0
			state = Enums.planet_states.idle
			if process_target in Enums.ship_types.values():
				get_node('/root/GameScene').add_child(Instancer.ship(process_target, null, self))
		
		GameState.emit_signal("update_ui")
	else:
		.process(delta)
	
func kill():
	faction = -1
	hitpoints = hitpoints_max
	
func _process(delta):
	if self.visible:
		.get_node("Sprite").rotation_degrees += rotation_speed * delta

func _draw():
	
	var polyline_color = Enums.player_colors[faction]
	var polyline_alpha = 0
	if GameState.get_selection() == self:
		polyline_color = Color(1,1,0)
		polyline_color = Color(1,1,1)
		polyline_alpha = 0.3
	elif is_hover:
		polyline_color = Color(1,1,1)
		polyline_alpha = 0.1
	elif Settings.get_show_planet_area():
		polyline_alpha = 0.025
	
	if polyline_alpha > 0:
		polyline_color.a = polyline_alpha
		draw_polyline(self.planet_convex_hull, polyline_color, 1, true)
	
	var polylgon_color = Enums.player_colors[faction]
	var polygon_alpha = 0
	#if GameState.get_selection() == self:
	#	polylgon_color = Color(1,1,0)
	#	polygon_alpha = 0.2
	#elif is_hover:
	#	polygon_alpha = 0.1
	if faction >= 0:
		polygon_alpha = 0.08
	
	if polygon_alpha > 0:
		
		polylgon_color.a = polygon_alpha
		draw_polygon(self.planet_convex_hull, [polylgon_color])

func get_target_point():
	var angle = 2 * PI * randf()
	#var r = (.get_node("AreaPlanet").shape as CircleShape2D).radius * randf()
	
	#var x = r * cos(angle) + self.global_transform.origin.x
	#var y = r * sin(angle) + self.global_transform.origin.y
	
	return position #Vector2(x, y)

func _on_PlanetArea_body_entered(entity: Entity):
	if self.planet_system == entity.planet_system:
		children.append(entity)
		if entity.object_type == Enums.object_types.asteroid:
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

func get_ships_by_type(type: int) -> Array:
	var children_by_type = []
	for child in children:
		if child.ship_type == type and child.faction == faction:
			children_by_type.append(child)
	return children_by_type
