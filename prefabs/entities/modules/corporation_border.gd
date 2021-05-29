extends Module

class_name ModuleCorporationBorder

var border_material: SpatialMaterial

func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	.init(_entity, params)
	
	border_material = SpatialMaterial.new()
	border_material.flags_transparent = true
	border_material.flags_unshaded = true
	border_material.flags_do_not_receive_shadows = true
	border_material.flags_disable_ambient_light = true
	border_material.albedo_color = Color(1,1,1,0.02)
	
	var combiner = CSGCombiner.new()
	combiner.material_override = border_material
	
	var outer = CSGCylinder.new()
	outer.radius = params.radius
	outer.height = 0.5
	outer.sides = 32
	outer.cast_shadow = false
	
	var inner = CSGCylinder.new()
	inner.radius = params.radius - 0.5
	inner.height = 0.5
	inner.sides = 32
	inner.cast_shadow = false
	inner.operation = CSGShape.OPERATION_SUBTRACTION
	
	combiner.add_child(outer)
	combiner.add_child(inner)
	_entity.add_child(combiner)
	
	self.entity.connect("entity_changed", self, "update_corporation_color")
	update_corporation_color()
	
	return self
	
func update_corporation_color():
	border_material.albedo_color = Enums.corporation_colors[self.entity.corporation_id]
