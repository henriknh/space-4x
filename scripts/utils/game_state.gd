extends Node

# Temporary
var selected_tile: Tile = null setget set_selected_tile
var selection: Entity = null setget set_selection
var hover: Tile setget set_hover
var loading: int = 0 setget set_loading
var saveFile: String = ''

# Persistent
var planet_system: PlanetSystem setget set_planet_system

signal planet_system_changed
signal selection_changed
signal hover_changed
signal state_changed
signal update_ui
signal loading_done
signal game_ready
signal overview_changed
	
func set_planet_system(_planet_system: PlanetSystem) -> void:
	if planet_system != _planet_system:
		planet_system = _planet_system
#		if not planet_system:
#			self.selection = null
		emit_signal("planet_system_changed")
	
func get_selected_tiles_entities():
	if selected_tile:
		var entities = []
		
		if selected_tile.entity:
			entities.append(selected_tile.entity)
		
		for ship in selected_tile.ships:
			if ship.corporation_id == Consts.PLAYER_CORPORATION:
				entities.append(ship)
		
		return entities
	else:
		return null

func set_selected_tile(_selected_tile: Tile):
	if selected_tile == _selected_tile:
		selected_tile = null
	else:
		selected_tile = _selected_tile
	
	var entities = get_selected_tiles_entities()
	if entities and entities.size() > 0:
		set_selection(entities[0])
	else:
		set_selection(null)

func set_selection(_selection: Entity):
	if selection == _selection:
		selection = null
	else:
		selection = _selection
	emit_signal("selection_changed")

func set_hover(_hover: Tile = null):
	hover = _hover
	emit_signal("hover_changed")

func set_loaded_game_state(state: Dictionary) -> void:
	self.state = state
	emit_signal("state_changed")
	
func set_loading(_loading: int) -> void:
	loading = _loading
	if loading == 0:
		emit_signal("loading_done")
