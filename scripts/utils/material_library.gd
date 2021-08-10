extends Node

var materials_opaque = {}
var materials_unshaded = {}
var materials_transparent = {}

enum MATERIAL_TYPES {
	OPAQUE,
	UNSHADED,
	TRANSPARENT
}

func _ready():
	for corporation_id in Enums.corporation_colors.keys():
		var opaque = SpatialMaterial.new()
		#opaque.flags_disable_ambient_light = true
		opaque.flags_do_not_receive_shadows = true
		opaque.albedo_color = Enums.corporation_colors[corporation_id]
		materials_opaque[corporation_id] = opaque
		
		var unshaded = SpatialMaterial.new()
		unshaded.flags_unshaded = true
		unshaded.flags_disable_ambient_light = true
		unshaded.flags_do_not_receive_shadows = true
		unshaded.albedo_color = Enums.corporation_colors[corporation_id]
		materials_unshaded[corporation_id] = unshaded
		
		var transparent = SpatialMaterial.new()
		transparent.flags_transparent = true
		transparent.flags_unshaded = true
		transparent.flags_disable_ambient_light = true
		transparent.flags_do_not_receive_shadows = true
		transparent.albedo_color = Enums.corporation_colors[corporation_id]
		transparent.albedo_color.a = 0.1
		materials_transparent[corporation_id] = transparent

func get_material(corporation_id: int, material_type: int = MATERIAL_TYPES.OPAQUE) -> SpatialMaterial:
	match material_type:
		MATERIAL_TYPES.OPAQUE:
			return materials_opaque[corporation_id]
		MATERIAL_TYPES.UNSHADED:
			return materials_unshaded[corporation_id]
		MATERIAL_TYPES.TRANSPARENT:
			return materials_transparent[corporation_id]
			
	breakpoint
	
	return null
