extends Node

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

const corporation_bound_texture = preload("res://assets/border_bound.png")
#const corporation_bound_material = preload("res://shaders/corporation_bounds_line.tres")

var corporation_original_data = []

func _connect_changed_signals():
	Corporations.connect("corporations_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")
	camera.connect("zoom_changed", self, "_render_corporations")

func _on_changed():
	_calc_original_data()
	_render_corporations()
	
func _calc_original_data():
	corporation_original_data = []
	for child in get_children():
		child.visible = false
		child.queue_free()
	
	var planet_system = GameState.get_planet_system()
	var planets = []
	for planet in get_tree().get_nodes_in_group('Planet'):
		if planet.planet_system == planet_system:
			planets.append(planet)
	
	for corporation in Corporations.get_all():
		var polygons = []
		for planet in planets:
			if planet.corporation_id == corporation.corporation_id:
				var polygon = []
				for point in planet.planet_convex_hull:
					polygon.append(point + planet.position)
				
				polygons.append(polygon)

		if polygons.size() >= 2:
			var i = 0
			while i < polygons.size():
				var j = i + 1
				var did_merge = false
				while j < polygons.size():
					var merge = Utils.merge_polygons_by_edge(polygons[i], polygons[j])
					if merge.size() == 1:
						polygons[i] = merge[0]
						polygons.remove(j)
						did_merge = true
					else:
						j += 1
				if not did_merge:
					i += 1
		
		var line = Line2D.new()
		line.default_color = corporation.color
		line.modulate.a = 1
		line.texture = corporation_bound_texture
		line.texture_mode = Line2D.LINE_TEXTURE_TILE
		line.sharp_limit = 3
		line.antialiased = true
		#line.material = corporation_bound_material.duplicate()
			
		add_child(line)
		
		corporation_original_data.append({
			"polygons": polygons,
			"line": line
		})

func _render_corporations():
	var width = camera.zoom.x * 3
	
	for corporation_data in corporation_original_data:
		for polygon in corporation_data.polygons:
	
			polygon = Utils.array_remove_intitial_duplicate(polygon)
			polygon = Utils.polygon_offset(polygon, width / 2)
			polygon = Utils.polygon_add_midpoint_split(polygon)
			
			corporation_data.line.points = polygon
			corporation_data.line.width = width
