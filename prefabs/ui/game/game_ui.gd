extends Control

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')

onready var camera = get_node('/root/GameScene/CameraRoot/Camera') as Camera
onready var node_resource_titanium: Label = $Resources/HBoxContainer/Titanium/Value
onready var node_resource_dust: Label = $Resources/HBoxContainer/Dust/Value
onready var node_debug: Control = $Debug
onready var node_fps: Label = $MainMenu/LabelFPS
onready var selection_overlay: Control = $SelectionOverlay
onready var previous_entities: HBoxContainer = $SelectionOverlay/SelectedEntity/PreviousEntities
onready var next_entities: HBoxContainer = $SelectionOverlay/SelectedEntity/NextEntities
onready var selected_entity_icon: TextureRect = $SelectionOverlay/SelectedEntity/SelectedEntity/EntityTypeIcon
onready var selected_entity_health: Label = $SelectionOverlay/SelectedEntity/SelectedEntity/EntityHealth
onready var user_actions: Control = $SelectionOverlay/UserActions

var _old_selection: Entity

func _ready():
	MenuState.push(self)
	
	GameState.connect("selection_changed", self, "update_selection_ui")
	GameState.connect("planet_system_changed", self, "update_selection_ui")
	update_selection_ui()
	
func _physics_process(_delta):
	node_fps.text = Engine.get_frames_per_second() as String

func _process(_delta):
	if is_instance_valid(GameState.selection) and GameState.selection.corporation_id == Consts.PLAYER_CORPORATION:
		var screen_pos = camera.unproject_position(GameState.selected_tile.global_transform.origin) - user_actions.rect_size / 2
		selection_overlay.rect_position = screen_pos

func init():
	var player_corporation = Corporations.get_corporation(Consts.PLAYER_CORPORATION)
	if player_corporation:
		player_corporation.connect("corporation_changed", self, "update_resources")
		update_resources()
	Settings.connect("settings_changed", self, "update_settings")
	
	if node_debug:
		node_debug.init()

func update_selection_ui():
	
	if GameState.selected_tile:
		GameState.selected_tile.connect("ship_changed", self,  "update_selection_ui")
	
	if GameState.planet_system and is_instance_valid(GameState.selection):
		
		
		var entities = GameState.get_selected_tiles_entities()
		var index = entities.find(GameState.selection)
		
		for child in previous_entities.get_children():
			previous_entities.remove_child(child)
		for i in range(0, index):
			var button = TextureButton.new()
			button.texture_normal = entities[i].icon
			button.connect("pressed", GameState, "set_selection", [entities[i]])
			previous_entities.add_child(button)
		
		for child in next_entities.get_children():
			next_entities.remove_child(child)
		for i in range(index + 1, entities.size()):
			var button = TextureButton.new()
			button.texture_normal = entities[i].icon
			button.connect("pressed", GameState, "set_selection", [entities[i]])
			next_entities.add_child(button)
		
		selected_entity_icon.texture = GameState.selection.icon
		selected_entity_health.visible = GameState.selection.health > 0
		selected_entity_health.text = GameState.selection.health as String
		
		for child in user_actions.get_children():
			user_actions.remove_child(child)
		
		var states = []
		if GameState.selection.corporation_id == Consts.PLAYER_CORPORATION and GameState.selection.has_node("States"):
			for state in GameState.selection.get_node("States").get_children():
				states = _add_state(states, state)
		
		for state in states:
			state.ui_update()
			user_actions.add_child(state.state_ui)
			
	selection_overlay.visible = GameState.selection != null

func _add_state(states, state):
	var can_add = state.ui_icon and state.ui_visible()
	
	if state.state_ui_unique_id != null:
		for s in states:
			if s.state_ui_unique_id == state.state_ui_unique_id:
				can_add = false
				break
	if can_add:
		states.append(state)
	
	return states

func update_resources():
	node_resource_titanium.text = Corporations.get_corporation(Consts.PLAYER_CORPORATION).resource_titanium as String
	node_resource_dust.text = Corporations.get_corporation(Consts.PLAYER_CORPORATION).resource_dust as String

func update_settings():
	node_fps.visible = Settings.get_show_fps()
	
func _on_game_menu():
	get_parent().add_child(game_menu_prefab.instance())

func _on_mouse_entered_ui():
	MenuState.set_over_ui(true)

func _on_mouse_exited_ui():
	MenuState.set_over_ui(false)
