extends Module

class_name ModuleShipLineOfSight


func init(_entity: Entity, params: Dictionary = {}) -> Spatial:
	.init(_entity, params)
	
	GameState.connect("planet_system_changed", self, "update_visibility")
	self.entity.connect("parent_changed", self, "update_visibility")
	return self
	
func update_visibility():
	var tile = self.entity.parent
	if tile:
		var planet_site = tile.get_parent()
		if planet_site:
			var planet_system = planet_site.get_parent()
			if planet_system and planet_system == GameState.curr_planet_system:
				self.entity.visible = true
				return
	
#	elif self.entity.corporation_id != Consts.PLAYER_CORPORATION:
#		self.entity.visible = show_ai_ship()
	
	self.entity.visible = true

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
