extends Node2D

onready var selection_polygon: Line2D = $Selection
onready var selection_material: ShaderMaterial = selection_polygon.material
onready var faction_bounds_container: Node = $FactionBoundsConatainer
onready var site_bounds_container: Node = $SiteBoundsConatainer
const faction_bound_texture = preload("res://assets/border_bound_faded.png")
const faction_bound_material = preload("res://shaders/faction_bounds_line.tres")

var width = 256

func _ready():
	Settings.connect("settings_changed", self, "_update_site_bounds")
	Factions.connect("factions_changed", self, "_update_faction_bounds")
	GameState.connect("selection_changed", self, "_update_selection")
	GameState.connect("state_changed", self, "_update_all")

func _update_node(node: Line2D, polygon: Array):
	
	if polygon[0] == polygon[polygon.size() - 1]:
		polygon = polygon.duplicate()
		polygon.remove(0)
	
	var polygon_offset: Array = []
	for i in range(polygon.size()):
		var j = polygon.size() - 1 if i == 0 else i - 1
		var k = 0 if i == polygon.size() - 1 else i + 1
		
		var d = (polygon[j] - polygon[i]).normalized() + (polygon[k] - polygon[i]).normalized()
		
		if not Geometry.is_point_in_polygon(d + polygon[i], polygon):
			d *= -1
		
		polygon_offset.append(d * width / 2 + polygon[i])
	
	var edgepoint = Utils.get_midpoint(polygon_offset[0], polygon_offset[polygon_offset.size() - 1])
	polygon_offset.insert(0, edgepoint)
	polygon_offset.append(edgepoint)
	
	node.points = polygon_offset
	node.width = width
	node.material.set_shader_param("width", width)
	node.visible = true

func _update_all():
	_update_selection()
	_update_faction_bounds()
	_update_site_bounds()
	
func _update_selection():
	var selection = GameState.get_selection()
	
	if selection == null or selection.entity_type != Enums.entity_types.planet:
		selection_polygon.visible = false
	else:
		print('Selection id: %d' % selection.id)
		print('Faction: %d' % selection.faction)
		var polygon: Array = []
		for point in selection.planet_convex_hull:
			polygon.append(point + selection.position)
			
		_update_node(selection_polygon, polygon)
	
func _update_faction_bounds():
	for child in faction_bounds_container.get_children():
		child.visible = false
		child.queue_free()
	
	var planet_system = GameState.get_planet_system()
	var planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == planet_system:
			planets.append(planet)
	
	for faction in Factions.factions:
		var polygons = []
		for planet in planets:
			if planet.faction == faction:
				var polygon = []
				for point in planet.planet_convex_hull:
					polygon.append(point + planet.position)
				
				polygons.append(polygon)

		if polygons.size() >= 2:
			var i = 0
			while i < polygons.size():
				var j = i + 1
				while j < polygons.size():
					var merge = Utils.merge_polygons_by_edge(polygons[i], polygons[j])
					if merge.size() == 1:
						polygons[i] = merge[0]
						polygons.remove(j)
					else:
						j += 1
				i += 1
		
		for polygon in polygons:
			
			var line = Line2D.new()
			line.default_color = Enums.player_colors[faction]
			line.texture = faction_bound_texture
			line.texture_mode = Line2D.LINE_TEXTURE_TILE
			line.sharp_limit = 3
			line.material = faction_bound_material.duplicate()
			
			_update_node(line, polygon)
			
			faction_bounds_container.add_child(line)

func _update_site_bounds():
	for child in site_bounds_container.get_children():
		child.visible = false
		child.queue_free()
		
	if not Settings.get_show_planet_area():
		return
	
	var edges = []
	var planet_system = GameState.get_planet_system()
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == planet_system:
			for i in range(planet.planet_convex_hull.size() - 1):
				var j = 0 if i + 1 == planet.planet_convex_hull.size() - 1 else i + 1
				var p1 = planet.planet_convex_hull[i] + planet.position
				var p2 = planet.planet_convex_hull[j] + planet.position
				
				var has_edge = false
				for edge in edges:
					if Utils.array_has(p1, edge) and Utils.array_has(p2, edge):
						has_edge = true
				
				if not has_edge:
					edges.append([p1, p2])
					
	for edge in edges:
		var line = Line2D.new()
		line.points = edge
		line.width = 1
		line.default_color = Color(1,1,1,0.025)
		line.antialiased = true
		
		site_bounds_container.add_child(line)
