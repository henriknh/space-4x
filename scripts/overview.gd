extends Tree

var timer
var show_list_items = ['Lava', 'Iron', 'Earth', 'Ice', 'Combat', 'Utility', 'Transport', 'Miner']
# Called when the node enters the scene tree for the first time.
func _ready():
	select_mode = 2
	set_hide_root(true)
	
	set_column_titles_visible(true)
	
	set_column_title(0, 'Name')
	set_column_title(1, 'Metal')
	set_column_title(2, 'Energy')
	set_column_title(3, 'Food')
	set_column_title(4, 'Ice')
	
	set_column_expand(0, true)
	set_column_expand(1, false)
	set_column_expand(2, false)
	set_column_expand(3, false)
	set_column_expand(4, false)
	
	set_column_min_width(1, 50)
	set_column_min_width(2, 50)
	set_column_min_width(3, 50)
	set_column_min_width(4, 50)
	
	timer = Timer.new()
	timer.set_one_shot(true)
	#timer.set_timer_process_mode(TIMER_PROCESS_FIXED)
	timer.set_wait_time(0.25)
	timer.connect("timeout", self, "_update_tree")
	add_child(timer)
	timer.start()

func _update_tree():
	clear()
	
	var root = create_item()
	
	var entities = []
	
	for show_list_item in show_list_items:
		entities += get_tree().get_nodes_in_group(show_list_item)
	
	for entity in entities:
		var item = create_item(root)
		item.set_text(0, entity.get_name())
		item.set_text(1, entity.get_metal() as String)
		item.set_text(2, entity.get_power() as String)
		item.set_text(3, entity.get_food() as String)
		item.set_text(4, entity.get_water() as String)


func _on_list_entity_toggled(is_show, entity_type):
	if is_show and show_list_items.find(entity_type) == -1:
		show_list_items.append(entity_type)
	else:
		var index = show_list_items.find(entity_type)
		if index >= 0:
			show_list_items.remove(index)
			
	_update_tree()
	timer.start()
