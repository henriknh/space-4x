extends VBoxContainer

const debug_overview_prefab = preload('res://prefabs/ui/game/debug/debug_overview/debug_overview.tscn')

onready var node_mouse_pos = $MousePos as Label
onready var node_event_queue_handled: Label = $EventQueueHandled
onready var node_event_queue_queued: Label = $EventQueueQueued
onready var node_spawner_corporation = $Spawner/Corporation as OptionButton
onready var node_spawner_ship_type = $Spawner/ShipType as OptionButton
onready var node_spawner_spawning = $Spawner/Spawning as Button

func _ready():
	
	if not OS.is_debug_build():
		queue_free()
	
	_update_ui()
	
func init():
	Settings.connect("settings_changed", self, "_update_ui")
	EventQueue.connect("event_queue_changed", self, "_update_ui")
	
	for corporation in Corporations.get_all():
		var image = Image.new()
		image.create(12, 12, false, Image.FORMAT_RGB8)
		image.fill(corporation.color)
		var texture = ImageTexture.new()
		texture.create_from_image(image)
		node_spawner_corporation.add_icon_item(texture, corporation.corporation_id as String, corporation.corporation_id)
	
	for ship_type in Enums.ship_types:
		node_spawner_ship_type.add_item(ship_type, Enums.ship_types[ship_type])
	var fighter_idx = node_spawner_ship_type.get_item_index(Enums.ship_types.fighter)
	node_spawner_ship_type.select(fighter_idx)

func _process(_delta):
	var mouse_pos = get_viewport().get_canvas_transform().affine_inverse().xform(get_viewport().get_mouse_position())
	node_mouse_pos.text = "(%d, %d)" % [stepify(mouse_pos.x, 0.01), stepify(mouse_pos.y, 0.01)]

func _update_ui():
	node_event_queue_handled.text = "Handled: %d" % EventQueue.handled_last_tick
	node_event_queue_queued.text = "Queued: %d" % EventQueue.queue.size()
	visible = Settings.is_debug()

func _on_show_debug_overview():
	get_node('/root/GameScene/CanvasLayer').add_child(debug_overview_prefab.instance())

