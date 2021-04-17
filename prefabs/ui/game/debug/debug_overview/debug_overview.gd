extends Control

const texture_ai_difficulty = preload("res://assets/icons/chart-bar.png")
const texture_ai_friendliness = preload("res://assets/icons/robot-happy.png")
const texture_ai_explorer = preload("res://assets/icons/compass.png")
const texture_rocks = preload("res://assets/icons/image-filter-hdr.png")
const texture_titanium = preload("res://assets/icons/cube.png")
const texture_astral_dust = preload("res://assets/icons/cloud.png")
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
	node_list.add_icon_item(texture_rocks, false)
	node_list.add_icon_item(texture_titanium, false)
	node_list.add_icon_item(texture_astral_dust, false)
	# Planets
	node_list.add_icon_item(texture_planet, false)
	# Ships
	var texture_ship_combat = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_combat, false)
	var texture_ship_explorer = texture_ship.duplicate()
	node_list.add_icon_item(texture_ship_explorer, false)
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
		
		node_list.add_item(corporation.asteroid_rocks as String, null, false)
		node_list.add_item(corporation.titanium as String, null, false)
		node_list.add_item(corporation.astral_dust as String, null, false)
		
		# Planets
		
		var planets = 0
		for planet in get_tree().get_nodes_in_group("Planet"):
			if planet.corporation_id == corporation.corporation_id:
				planets += 1
		node_list.add_item(planets as String, null, false)
		
		# Ships
		
		var combat = 0
		var explorer = 0
		var miner = 0
		for ship in get_tree().get_nodes_in_group("Ship"):
			if ship.corporation_id == corporation.corporation_id:
				match ship.ship_type:
					Enums.ship_types.combat:
						combat += 1
					Enums.ship_types.explorer:
						explorer += 1
					Enums.ship_types.miner:
						miner += 1
		node_list.add_item(combat as String, null, false)
		node_list.add_item(explorer as String, null, false)
		node_list.add_item(miner as String, null, false)
		
		

func _on_close():
	MenuState.pop()
