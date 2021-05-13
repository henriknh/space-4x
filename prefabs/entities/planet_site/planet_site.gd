extends Entity

class_name PlanetSite

onready var node_collision: CollisionPolygon = $Area/CollisionPolygon
onready var node_mesh: MeshInstance = $Mesh

var polygon = []

func _ready():
	add_to_group('Persist')
	add_to_group('PlanetSite')
	
	node_collision.polygon = polygon
	
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_POINTS)
	for point in polygon:
		st.add_vertex(Vector3(point.x, 0, point.y))
	node_mesh.mesh = st.commit()

func generate_site():
	pass
