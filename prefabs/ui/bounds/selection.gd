extends Line2D

var original_selection: Array = []

func _connect_changed_signals():
	GameState.connect("selection_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")

func _on_changed():
	_calc_original_data()
	_render_selection()

func _calc_original_data():
	var selection = GameState.get_selection()
	
	if selection == null or selection.entity_type != Enums.entity_types.planet:
		visible = false
		original_selection = []
	else:
		print('Selection id: %d' % selection.id)
		print('Faction: %d' % selection.faction)
		
		original_selection = []
		for point in selection.planet_convex_hull:
			original_selection.append(point + selection.position)

func _render_selection():
	var width = 256
	
	var polygon = Utils.array_remove_intitial_duplicate(original_selection)
	polygon = Utils.polygon_offset(polygon, width / 2)
	polygon = Utils.polygon_add_midpoint_split(polygon)
	
	points = polygon
	width = width
	visible = true
