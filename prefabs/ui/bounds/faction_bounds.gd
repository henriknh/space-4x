extends Node

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

const faction_bound_texture = preload("res://assets/border_bound.png")
#const faction_bound_material = preload("res://shaders/faction_bounds_line.tres")

var faction_original_data = []

func _connect_changed_signals():
	Factions.connect("factions_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")
	camera.connect("zoom_changed", self, "_render_factions")

func _on_changed():
	_calc_original_data()
	_render_factions()
	
func _calc_original_data():
	faction_original_data = []
	for child in get_children():
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
		
		var line = Line2D.new()
		line.default_color = Enums.player_colors[faction]
		line.modulate.a = 1
		line.texture = faction_bound_texture
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.sharp_limit = 3
		#line.material = faction_bound_material.duplicate()
			
		add_child(line)
		
		faction_original_data.append({
			"polygons": polygons,
			"line": line
		})

func _render_factions():
	var width = camera.zoom.x * 3
	
	for faction_data in faction_original_data:
		for polygon in faction_data.polygons:
	
			polygon = Utils.array_remove_intitial_duplicate(polygon)
			polygon = Utils.polygon_offset(polygon, width / 2)
			polygon = Utils.polygon_add_midpoint_split(polygon)
			
			faction_data.line.points = polygon
			faction_data.line.width = width
