extends Entity

class_name Turret

var parent # Tile
onready var node_mesh: MeshInstance = $Mesh
onready var node_light: OmniLight = $Mesh/OmniLight
onready var node_anim: AnimationPlayer = $AnimationPlayer

func _ready():
	parent = get_parent().get_parent()
	node_light.light_color = Enums.corporation_colors[get_parent().corporation_id]
	node_mesh.material_override = MaterialLibrary.get_material(0)
	node_anim.play("BeamPulse")
	corporation_id = parent.corporation_id
	
