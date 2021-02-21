extends Node2D

onready var selection_polygon: Line2D = $Selection
onready var selection_material: ShaderMaterial = selection_polygon.material
onready var bounds_container: Node = $SiteBoundsConatainer

func _ready():
	GameState.connect("selection_changed", self, "_update_selection")
	Factions.connect("factions_changed", self, "_update_bounds")

func _update_selection():
	var selection = GameState.get_selection()
	
	if selection == null or selection.entity_type != Enums.entity_types.planet:
		selection_polygon.visible = false
	else:
		var polygon: Array = []
		var origin: Vector2 = Vector2.ZERO
		
		for point in selection.planet_convex_hull:
			var transformed: Vector2 = point + selection.position
			polygon.append(transformed)
			origin += transformed
			print(transformed)
			
		origin /= selection.planet_convex_hull.size()
		
		selection_material.set_shader_param("origin", origin)
		selection_polygon.points = polygon
		selection_polygon.visible = true
		
	
func _update_bounds():
	print('_update_bounds')
