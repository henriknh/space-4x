extends Module

class_name ModuleShipLineOfSight


func init(_entity: Entity) -> Spatial:
	.init(_entity)
	
#	if self.entity.corporation_id != Consts.PLAYER_CORPORATION:
#		self.entity.visible = show_ai_ship()
#	else:
#		self.entity.visible = true
	
	GameState.connect("planet_system_changed", self, "update_visibility")
	self.entity.connect("parent_changed", self, "update_visibility")
	return self
	
func update_visibility():
	if self.entity.parent and self.entity.parent.get_parent() == GameState.curr_planet_system:
		self.entity.visible = true
	else:
		self.entity.visible = false

func show_ai_ship() -> bool:
	if not self.entity.parent:
		return false
	for neighbor_ship in self.entity.parent.ships:
		if neighbor_ship.corporation_id == Consts.PLAYER_CORPORATION:
			return true
	
	for neighbor_tile in self.entity.parent.neighbors:
		for neighbor_ship in neighbor_tile.ships:
			if neighbor_ship.corporation_id == Consts.PLAYER_CORPORATION:
				return true
	return false
