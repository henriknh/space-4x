extends Module

class_name PlanetSystemShipLineOfSight


func init(_entity: Entity) -> Spatial:
	.init(_entity)
	GameState.connect("planet_system_changed", self, "update_visibility")
	return self
	
func update_visibility():
	var vis = self.entity == GameState.curr_planet_system
	for tile in self.entity.tiles:
		tile.visible = vis
