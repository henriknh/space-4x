extends Entity

class_name PlanetSite

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_border: CSGCombiner = $Border
onready var node_border_material: SpatialMaterial = SpatialMaterial.new()
onready var node_csg_polygon: CSGPolygon = $Border/CSGPolygon
onready var node_csg_polygon_deflated: CSGPolygon = $Border/CSGPolygonDeflated

var polygon = []
var tiles = [] 
var planet: Planet

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSite')
	
	node_collision.polygon = polygon
	
	node_border_material.flags_transparent = true
	node_border_material.flags_unshaded = true
	node_border_material.flags_do_not_receive_shadows = true
	node_border_material.flags_disable_ambient_light = true
	node_border_material.albedo_color = Color(1,1,1,0)
	node_border.material_override = node_border_material
	
	var polygon_deflated = Geometry.offset_polygon_2d(polygon, -0.2)[0]
	node_csg_polygon.polygon = polygon
	node_csg_polygon_deflated.polygon = polygon_deflated
	
	planet.connect("entity_changed", self, "update_border_color")
	GameState.connect("planet_system_changed", self, "update_overview")
	update_border_color()

func update_border_color():
	node_border_material.albedo_color = Enums.corporation_colors[self.planet.corporation_id]
	
func update_overview():
	node_csg_polygon.visible = not (GameState.curr_planet_system == null and self.planet.corporation_id == 0)
	node_csg_polygon_deflated.visible = GameState.curr_planet_system != null
