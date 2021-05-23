extends Module

class_name PlanetSystemShipLineOfSight

func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	.init(_entity, params)
	GameState.connect("planet_system_changed", self, "update_visibility", [], 1)
	return self
	
func update_visibility():
	self.entity.get_node('Grid').visible = self.entity == GameState.curr_planet_system
#	for tile in self.entity.tiles:
#		tile.visible = vis
#		call_deferred("set_tile_visible", tile, vis)

func set_tile_visible(tile, vis):
	tile.visible = vis
