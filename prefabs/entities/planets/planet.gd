extends entity

class_name planet

var is_hover = false

var children = []

var prefab_lava = preload('res://assets/PixelPlanets/LavaWorld/LavaWorld.tscn')
var prefab_iron = preload('res://assets/PixelPlanets/GasPlanet/GasPlanet.tscn')
var prefab_earth_1 = preload('res://assets/PixelPlanets/LandMasses/LandMasses.tscn')
var prefab_earth_2 = preload('res://assets/PixelPlanets/Rivers/Rivers.tscn')
var prefab_ice = preload('res://assets/PixelPlanets/IceWorld/IceWorld.tscn')

func create():
	entity_type = Enums.entity_types.planet
	planet_size = WorldGenerator.rng.randf_range(1.0, 2.0)
	rotation_speed = WorldGenerator.rng.randf_range(-1, 1) * 10
	label = NameGenerator.get_name_planet()
	indestructible = true
	hitpoints_max = 250
	.create()
	
func ready():
	get_node("InfoUI").set_label(label)
	(get_node("PlanetArea/PlanetAreaCollision") as CollisionPolygon2D).polygon = self.planet_convex_hull
	
	Settings.connect("settings_changed", self, "update")
	
	var instance = null
	match planet_type:
		Enums.planet_types.lava:
			instance = prefab_lava.instance()
			add_to_group('Lava')
		Enums.planet_types.iron:
			instance = prefab_iron.instance()
			add_to_group('Iron')
		Enums.planet_types.earth:
			if WorldGenerator.rng.randi() % 2 == 0:
				instance = prefab_earth_1.instance()
			else:
				instance = prefab_earth_2.instance()
			add_to_group('Earth')
		Enums.planet_types.ice:
			instance = prefab_ice.instance()
			add_to_group('Ice')
			
	var radius = (planet_size * 200) / 2
	(instance as Control).rect_scale = Vector2(planet_size, planet_size)
	(instance as Control).set_position(Vector2(-radius, -radius))
	($PlanetCollision.shape as CircleShape2D).radius = radius

	add_child(instance)
	.ready()

func process():
	.process()
	
func kill():
	faction = -1
	hitpoints = hitpoints_max
	
func _process(delta):
	if self.visible:
		.get_node("Sprite").rotation_degrees += rotation_speed * delta
		
func _draw():
	if Settings.get_show_planet_area():
		draw_polyline(self.planet_convex_hull, Color(1,1,1,0.025), 1, true)
	
	if self in GameState.get_selection():
		draw_polygon(self.planet_convex_hull, [Color(1, 1, 0, 0.1)])
		draw_polyline(self.planet_convex_hull, Color(1, 1, 0, 0.25), 1, true)
	elif is_hover:
		draw_polygon(self.planet_convex_hull, [Color(1, 1, 1, 0.01)])
		draw_polyline(self.planet_convex_hull, Color(1, 1, 1, 0.05), 1, true)

func get_target_point():
	var angle = 2 * PI * randf()
	#var r = (.get_node("AreaPlanet").shape as CircleShape2D).radius * randf()
	
	#var x = r * cos(angle) + self.global_transform.origin.x
	#var y = r * sin(angle) + self.global_transform.origin.y
	
	return position #Vector2(x, y)

func _on_PlanetArea_body_entered(entity: entity):
	if self.planet_system == entity.planet_system:
		children.append(entity)
		entity.parent = self

func _on_PlanetArea_body_exited(entity: entity):
	if self.planet_system == entity.planet_system:
		children.erase(entity)

func _on_PlanetArea_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed and (event as InputEventMouseButton).button_index == BUTTON_LEFT:
		GameState.set_selection(self)
		for ship in get_tree().get_nodes_in_group('Ship'):
			if ship.planet_system == self.planet_system and ship.has_method("set_target_id"):
				ship.set_target_id(self.id)

func _on_hover_enter():
	is_hover = true
	update()

func _on_hover_leave():
	is_hover = false
	update()
