extends VBoxContainer

const debug_overview_prefab = preload('res://prefabs/ui/game/debug/debug_overview/debug_overview.tscn')

var spawner_target_texture = preload('res://assets/icons/target.png')

onready var node_mouse_pos = $MousePos as Label
onready var node_spawner_corporation = $Spawner/Corporation as OptionButton
onready var node_spawner_ship_type = $Spawner/ShipType as OptionButton
onready var node_spawner_set_target = $Spawner/SetSpawnTarget as Button
onready var node_spawner_spawn = $Spawner/Spawn as Button

var setting_target = false
var spawner_target: Node2D

func _ready():
	_update_ui()
	
func init():
	Settings.connect("settings_changed", self, "_update_ui")
	
	for corporation in Corporations.get_all():
		var image = Image.new()
		image.create(12, 12, false, Image.FORMAT_RGB8)
		image.fill(corporation.color)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		node_spawner_corporation.add_icon_item(texture, corporation.corporation_id as String, corporation.corporation_id)
	
	for ship_type in Enums.ship_types:
		node_spawner_ship_type.add_item(ship_type, Enums.ship_types[ship_type])
	var combat_idx = node_spawner_ship_type.get_item_index(Enums.ship_types.combat)
	node_spawner_ship_type.select(combat_idx)

func _process(delta):
	var mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position())
	node_mouse_pos.text = "(%d, %d)" % [stepify(mouse_pos.x, 0.01), stepify(mouse_pos.y, 0.01)]

func _input(event: InputEvent) -> void:
	if setting_target and event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			setting_target = false
			get_tree().set_input_as_handled()
			if not spawner_target:
				spawner_target = Sprite.new()
				spawner_target.texture = spawner_target_texture
				get_node('/root/GameScene').add_child(spawner_target)
			spawner_target.position = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position())
			_update_ui()
			
func _update_ui():
	node_spawner_set_target.disabled = setting_target
	node_spawner_spawn.disabled = spawner_target == null or setting_target
	if spawner_target:
		spawner_target.visible = Settings.is_debug()
		spawner_target.scale = (get_node('/root/GameScene/Camera') as Camera2D).zoom
	visible = Settings.is_debug()

func _on_set_spawn_target():
	setting_target = true

func _on_spawn_ship():
	var override = {
		'planet_system': GameState.get_planet_system(),
		'position': spawner_target.position,
		'corporation_id': node_spawner_corporation.get_selected_id()
	}
	var ship = Instancer.ship(node_spawner_ship_type.get_selected_id(), null, null, override)
	get_node('/root/GameScene').add_child(ship)


func _on_show_debug_overview():
	get_node('/root/GameScene/CanvasLayer').add_child(debug_overview_prefab.instance())

