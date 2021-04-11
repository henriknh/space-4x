extends Control

const distribution_swap_prefab = preload('res://prefabs/ui/game/distribution_swap/distribution_swap.tscn')

onready var node_research: TextureButton = $CenterResearch/Research
onready var node_produce: MenuButton = $Produce
onready var node_convert: MenuButton = $Convert
onready var node_swap: TextureButton = $CenterTransfer/Swap

var _old_selection: Entity

func _ready():
	GameState.connect("selection_changed", self, "_new_selection")
	_update_ui()

func _new_selection():
	if _old_selection:
		_old_selection.disconnect("entity_changed", self, "_update_ui")
	
	var selection = GameState.get_selection()
	if selection:
		selection.connect("entity_changed", self, "_update_ui")
	
	_old_selection = selection
	
	_update_ui()
	
func _update_ui():
	var selection = GameState.get_selection()
	
	var research_disabled = true
	var produce_disabled = true
	var convert_disabled = true
	var swap_disabled = true
		
	if selection and selection.corporation_id == Consts.PLAYER_CORPORATION:
		var corporation = GameState.get_selection().get_corporation()
		
		research_disabled = corporation.astral_dust < Consts.RESEARCH_COST_ASTRAL_DUST
		produce_disabled = corporation.titanium < Consts.SHIP_COST_TITANIUM
		convert_disabled = corporation.asteroid_rocks < Consts.RESOURCE_CONVERTION_COST
		swap_disabled = selection.ships.size() == 0 and selection.planet_disabled_ships == 0
	
	node_research.disabled = research_disabled
	node_produce.disabled = produce_disabled
	node_convert.disabled = convert_disabled
	node_swap.disabled = swap_disabled
	
func _create_ship(ship_type: int):
	if not GameState.get_selection():
		return
	var selection = GameState.get_selection()
	var corporation = selection.get_corporation()
	if corporation.titanium >= Consts.SHIP_COST_TITANIUM:
		corporation.titanium -= Consts.SHIP_COST_TITANIUM
		GameState.get_selection().set_entity_process(Enums.planet_states.produce, ship_type, Consts.SHIP_PRODUCTION_TIME)

func _on_produce():
	var menu = node_produce.get_popup()
	menu.clear()
	menu.add_item('Combat', Enums.ship_types.combat)
	menu.add_item('Explorer', Enums.ship_types.explorer)
	menu.add_item('Miner', Enums.ship_types.miner)
	menu.connect("id_pressed", self, "_create_ship")
	menu.popup()

func _convert_resource(convertion_resource: int):
	if not GameState.get_selection():
		return
	var selection = GameState.get_selection()
	var corporation = selection.get_corporation()
	if corporation.asteroid_rocks >= Consts.RESOURCE_CONVERTION_COST:
		corporation.asteroid_rocks -= Consts.RESOURCE_CONVERTION_COST
		selection.set_entity_process(Enums.planet_states.convertion, convertion_resource, Consts.RESOURCE_CONVERTION_TIME)

func _on_convert():
	var menu = node_convert.get_popup()
	menu.clear()
	menu.add_item('Titanium', Enums.resource_types.titanium)
	menu.add_item('Astral Dust', Enums.resource_types.astral_dust)
	menu.connect("id_pressed", self, "_convert_resource")
	menu.popup()

func _on_swap():
	print('swap')
	get_node('/root/GameScene/CanvasLayer').add_child(distribution_swap_prefab.instance())
