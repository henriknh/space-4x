extends Line2D

onready var camera = get_node('/root/GameScene/Camera') as Camera2D

var original_selection: Array = []
var selection_has_corporation = false

func _connect_changed_signals():
	GameState.connect("selection_changed", self, "_on_changed")
	GameState.connect("state_changed", self, "_on_changed")
	camera.connect("zoom_changed", self, "_render_selection")

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
		print('Coporation: %d' % selection.corporation_id)
		
		selection_has_corporation = selection.corporation_id > 0
		if selection_has_corporation:
			default_color = Enums.corporation_colors[selection.corporation_id]
			modulate.a = 1
		else:
			default_color = Color(1,1,1,1)
			modulate.a = 0.4
		
		original_selection = []
		for point in selection.planet_convex_hull:
			original_selection.append(point + selection.position)

func _render_selection():
	var width = camera.zoom.x * 3
	var offset = (width * 1.5) if selection_has_corporation else (width * 0.5)
	
	var polygon = Utils.array_remove_intitial_duplicate(original_selection)
	polygon = Utils.polygon_offset(polygon, offset)
	polygon = Utils.polygon_add_midpoint_split(polygon)
	
	self.points = polygon
	self.width = width
	self.visible = true
