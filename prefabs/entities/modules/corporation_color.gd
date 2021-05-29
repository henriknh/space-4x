extends Module

class_name ModuleCorporationColor

var node_mesh_material: SpatialMaterial

func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	.init(_entity, params)
	
	node_mesh_material = SpatialMaterial.new()
	
	(self.entity.get_node("Mesh") as MeshInstance).material_override = node_mesh_material
	
	self.entity.connect("entity_changed", self, "update_corporation_color")
	update_corporation_color()
	
	return self
	
func update_corporation_color():
	node_mesh_material.albedo_color = Enums.corporation_colors[self.entity.corporation_id]
