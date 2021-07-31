extends Spatial

onready var tile = get_parent().get_parent()

onready var ships_node = $Sprite3D/Viewport/VBoxContainer/Ships/Value
onready var health_node = $Sprite3D/Viewport/VBoxContainer/Health/Value
onready var camera = get_node('/root/GameScene/CameraRoot/Camera') as Camera

func _ready():
	tile.connect("ship_changed", self, "update_ui")
	update_ui()
	
func update_ui():
	visible = tile.ships.size() >= 1
	
	var ship_count = 0
	var health = 0
	for ship in tile.ships:
		ship.connect("entity_changed", self, "update_ui")
		ship_count += ship.ship_count
		health += ship.health
	
	ships_node.text = ship_count as String
	health_node.text = health as String
