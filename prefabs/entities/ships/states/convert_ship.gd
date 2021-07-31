extends State

export(Enums.ship_types) var ship_type
export(Texture) var texture
export var speed = 50

var ui_texture

func _ready():
	if not ship_type:
		breakpoint
	if not texture:
		breakpoint

func update(delta):
	ui_progress += delta * speed
	
	if ui_progress >= 100:
		var override = {}
		if ship_type == Enums.ship_types.carrier:
			override["ship_count"] = 1
		
		var new_ship = Instancer.ship(ship_type, host, override)
		get_node('/root/GameScene').add_child(new_ship)
		if GameState.selection == host:
			GameState.selection = new_ship
			var index = GameState.selected_tile.ships.find(host)
			GameState.selected_tile.ships.remove(index)
			GameState.selected_tile.ships.insert(index, new_ship)
			GameState.selected_tile.emit_signal("ship_changed")
		host.queue_free()
		return true
	
	return
	

func ui_data():
	var disabled = false
	match ship_type:
		Enums.ship_types.carrier:
			disabled = host.ship_count < 5
	
	return {
		"disabled": disabled,
		"texture": texture
	}
