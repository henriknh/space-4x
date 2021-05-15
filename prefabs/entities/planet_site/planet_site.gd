extends Entity

class_name PlanetSite

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_csg_polygon: CSGPolygon = $Border/CSGPolygon
onready var node_csg_polygon_deflated: CSGPolygon = $Border/CSGPolygonDeflated

var polygon = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSite')
	
	node_collision.polygon = polygon
	
	var polygon_deflated = Geometry.offset_polygon_2d(polygon, -1)[0]
	node_csg_polygon.polygon = polygon
	node_csg_polygon_deflated.polygon = polygon_deflated

func generate_site():
	pass
