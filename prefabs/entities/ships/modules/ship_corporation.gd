extends Module

class_name ModuleShipCorporation

var node_mesh_material: SpatialMaterial

func init(_entity: Entity) -> Spatial:
	.init(_entity)
	
	node_mesh_material = (self.entity.get_node("Mesh") as MeshInstance).material_override
	
	self.entity.connect("entity_changed", self, "update_corporation_color")
	update_corporation_color()
	
	return self
	
func update_corporation_color():
	node_mesh_material.albedo_color = Enums.corporation_colors[self.entity.corporation_id]
