extends Node

var script_entity = preload('res://prefabs/entities/entity.gd')

# Ship
var prefab_ship = preload('res://prefabs/entities/ships/ship.tscn')
var script_ship = preload('res://prefabs/entities/ships/ship.gd')
var script_combat = preload('res://prefabs/entities/ships/ship_combat.gd')
var script_explorer = preload('res://prefabs/entities/ships/ship_explorer.gd')
var script_miner = preload('res://prefabs/entities/ships/ship_miner.gd')
var script_transport = preload('res://prefabs/entities/ships/ship_transport.gd')

func ship(ship_type: int, copy_from: entity = null, inherit: entity = null) -> entity:
	
	var instance = prefab_ship.instance()
	
	match ship_type:
		Enums.ship_types.combat:
			instance.set_script(script_combat)
		Enums.ship_types.explorer:
			instance.set_script(script_explorer)
		Enums.ship_types.miner:
			instance.set_script(script_miner)
		Enums.ship_types.transport:
			instance.set_script(script_transport)

	if copy_from:
		for propery in script_ship.get_script_property_list():
			instance.set(propery.name, copy_from.get(propery.name))
		
		instance.position = copy_from.position
		instance.rotation_degrees = copy_from.rotation_degrees
	
	if inherit:
		instance.planet_system = inherit.planet_system
		instance.faction = inherit.faction
		instance.position = inherit.position
		instance.parent = inherit
	
	instance.ship_type = ship_type
	
	if copy_from == null:
		instance.create()
	else:
		instance.ready()
	
	return instance
