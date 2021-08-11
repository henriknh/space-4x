extends Control

const texture_ai_difficulty = preload("res://assets/icons/debug_ai_difficulty.png")
const texture_ai_friendliness = preload("res://assets/icons/debug_ai_friendliness.png")
const texture_ai_explorer = preload("res://assets/icons/debug_ai_explorer.png")
const texture_resource_titanium = preload("res://assets/icons/titanium.png")
const texture_resource_dust = preload("res://assets/icons/dust.png")
const texture_ship = preload("res://assets/icons/ship.png")
const texture_planet = preload("res://assets/icons/planet.png")

onready var node_list: ItemList = $VBoxContainer/ItemList

func _ready():
	MenuState.push(self)
	
	var timer = Timer.new()
	timer.wait_time = 0.25
	timer.connect("timeout", self, "_update_ui")
	add_child(timer)
	timer.start()
	
	_update_ui()
	
func _update_ui():
	node_list.clear()
	node_list.max_columns = 11
	node_list.fixed_icon_size = Vector2(24, 24)
	
	# Icon
	node_list.add_item("", null, false)
	# AI properties
	node_list.add_icon_item(texture_ai_difficulty, false)
	node_list.add_icon_item(texture_ai_friendliness, false)
	node_list.add_icon_item(texture_ai_explorer, false)
	# Resources
	node_list.add_icon_item(texture_resource_titanium, false)
	node_list.add_icon_item(texture_resource_dust, false)
	# Planets
	node_list.add_icon_item(texture_planet, false)
	# Ships
	var texture_ship_explorer = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_explorer, false)
	var texture_ship_fighter = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_fighter, false)
	var texture_ship_carrier = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_carrier, false)
	var texture_ship_miner = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_miner, false)
	
	for corporation in Corporations.get_all():
		
		# Icon
		
		var icon = Image.new()
		icon.create(20, 20, true, Image.FORMAT_RGBA8)
		icon.fill(corporation.color)
		
		var icon_text = ImageTexture.new()
		icon_text.create_from_image(icon)

		node_list.add_icon_item(icon_text, false)
		
		# AI properties
		
		if corporation.is_computer:
			node_list.add_item(corporation.difficulty as String, null, false)
			node_list.add_item(corporation.friendliness as String, null, false)
			node_list.add_item(corporation.explorer as String, null, false)
			
		else:
			node_list.add_item("", null, false)
			node_list.add_item("", null, false)
			node_list.add_item("", null, false)
			
		# Resources
		node_list.add_item(corporation.resource_titanium as String, null, false)
		node_list.add_item(corporation.resource_dust as String, null, false)
		
		# Planets
		
		var planets = 0
		for planet in get_tree().get_nodes_in_group("Planet"):
			if planet.corporation_id == corporation.corporation_id:
				planets += 1
		node_list.add_item(planets as String, null, false)
		
		# Ships
		
		var explorer = 0
		var fighter = 0
		var carrier = 0
		var miner = 0
		for ship in get_tree().get_nodes_in_group("Ship"):
			if ship.corporation_id == corporation.corporation_id:
				if ship is Explorer:
					explorer += 1
				elif ship is Fighter:
					fighter += 1
				elif ship is Carrier:
					carrier += 1
				elif ship is Miner:
					miner += 1
		node_list.add_item(explorer as String, null, false)
		node_list.add_item(fighter as String, null, false)
		node_list.add_item(carrier as String, null, false)
		node_list.add_item(miner as String, null, false)
		
		

func _on_close():
	MenuState.pop()
