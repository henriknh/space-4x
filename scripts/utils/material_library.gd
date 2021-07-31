extends Node

var materials_opaque = {}
var materials_transparent = {}

func _ready():
	for corporation_id in Enums.corporation_colors.keys():
		var opaque = SpatialMaterial.new()
		#opaque.flags_unshaded = true
		opaque.flags_disable_ambient_light = true
		opaque.flags_do_not_receive_shadows = true
		opaque.albedo_color = Enums.corporation_colors[corporation_id]
		materials_opaque[corporation_id] = opaque
		
		var transparent = SpatialMaterial.new()
		transparent.flags_transparent = true
		transparent.flags_unshaded = true
		transparent.flags_disable_ambient_light = true
		transparent.flags_do_not_receive_shadows = true
		transparent.albedo_color = Enums.corporation_colors[corporation_id]
		transparent.albedo_color.a = 0.1
		materials_transparent[corporation_id] = transparent

func get_material(corporation_id: int, opaque: bool = true) -> SpatialMaterial:
	if opaque:
		return materials_opaque[corporation_id]
	else:
		return materials_transparent[corporation_id]
		
