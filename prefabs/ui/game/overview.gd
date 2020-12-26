extends VBoxContainer

var tree = null
var show_list_items = ['Lava', 'Iron', 'Earth', 'Ice', 'Combat', 'Utility', 'Transport', 'Miner']

func _ready():
	tree = $ItemTree
	
	tree.select_mode = 2
	tree.set_hide_root(true)
	
	tree.set_column_titles_visible(true)
	
	tree.set_column_title(0, 'Name')
	tree.set_column_title(1, 'Metal')
	tree.set_column_title(2, 'Energy')
	tree.set_column_title(3, 'Food')
	tree.set_column_title(4, 'Ice')
	
	tree.set_column_expand(0, true)
	for i in range(1, 5):
		tree.set_column_expand(i, false)
		tree.set_column_min_width(i, 50)

func update_ui():
	if !visible:
		return
	
	var lava = 0
	var iron = 0
	var earth = 0
	var ice = 0
	
	var combat = 0
	var utility = 0
	var transport = 0
	var miner = 0
	
	tree.clear()
	
	var root = tree.create_item()
	
	var entities = []
	
	for show_list_item in show_list_items:
		entities += get_tree().get_nodes_in_group(show_list_item)
	
	for entity in entities:
		if entity.planet_system == GameState.get_planet_system():
			var item = tree.create_item(root)
			item.set_text(0, entity.get_name())
			item.set_text(1, Formatter.round_to_dec(entity.metal, 2) as String)
			item.set_text(2, Formatter.round_to_dec(entity.power, 2) as String)
			item.set_text(3, Formatter.round_to_dec(entity.food, 2) as String)
			item.set_text(4, Formatter.round_to_dec(entity.water, 2) as String)
			
			if entity.is_in_group('Lava'):
				lava = lava + 1
			elif entity.is_in_group('Iron'):
				iron = iron + 1
			elif entity.is_in_group('Earth'):
				earth = earth + 1
			elif entity.is_in_group('Ice'):
				ice = ice + 1
			elif entity.is_in_group('Combat'):
				combat = combat + 1
			elif entity.is_in_group('Utility'):
				utility = utility + 1
			elif entity.is_in_group('Transport'):
				transport = transport + 1
			elif entity.is_in_group('Miner'):
				miner = miner + 1
	
	$Planets/CheckboxLava.text = lava as String
	$Planets/CheckboxIron.text = iron as String
	$Planets/CheckboxEarth.text = earth as String
	$Planets/CheckboxIce.text = ice as String
	
	$Ships/CheckboxCombat.text = combat as String
	$Ships/CheckboxUtility.text = utility as String
	$Ships/CheckboxTransport.text = transport as String
	$Ships/CheckboxMiner.text = miner as String


func _on_list_entity_toggled(is_show, entity_type):
	if is_show and show_list_items.find(entity_type) == -1:
		show_list_items.append(entity_type)
	else:
		var index = show_list_items.find(entity_type)
		if index >= 0:
			show_list_items.remove(index)
	
	update_ui()
