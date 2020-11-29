extends Node

var save_file_path = "user://savegame.save"

func has_save() -> bool:
	var save_game = File.new()
	return save_game.file_exists(save_file_path)

func save_game() -> void:
	var save_game = File.new()
	save_game.open(save_file_path, File.WRITE)
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	print('Saving %d nodes' % save_nodes.size())
	for node in save_nodes:
		# Check the node is an instanced scene so it can be instanced again during load.
		if node.filename.empty():
			print("persistent node '%s' is not an instanced scene, skipped" % node.name)
			continue

		# Check the node has a save function.
		if !node.has_method("save"):
			print("persistent node '%s' is missing a save() function, skipped" % node.name)
			continue

		# Call the node's save function.
		var node_data = node.call("save")

		# Store the save dictionary as a new line in the save file.
		save_game.store_line(to_json(node_data))
	save_game.close()

func load_game(target) -> bool:
	var save_game = File.new()
	if not save_game.file_exists(save_file_path):
		return false# Error! We don't have a save to load.

	# We need to revert the game state so we're not cloning objects
	# during loading. This will vary wildly depending on the needs of a
	# project, so take care with this step.
	# For our example, we will accomplish this by deleting saveable objects.
	var save_nodes = get_tree().get_nodes_in_group("Persist")
	for i in save_nodes:
		i.queue_free()

	# Load the file line by line and process that dictionary to restore
	# the object it represents.
	save_game.open(save_file_path, File.READ)
	while save_game.get_position() < save_game.get_len():
		# Get the saved dictionary from the next line in the save file
		var node_data = parse_json(save_game.get_line())

		# Firstly, we need to create the object and add it to the tree and set its position.
		var new_object = load(node_data["filename"]).instance()
		new_object.visible = false
		new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
		if node_data["_ship_target_x"] and node_data["_ship_target_y"]:
			new_object._ship_target = Vector2(node_data["_ship_target_x"], node_data["_ship_target_y"])
		else:
			new_object._ship_target = null

		# Now we set the remaining variables.
		for i in node_data.keys():
			if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y" or i == "_ship_target_x" or i == "_ship_target_y":
				continue
			new_object.set(i, node_data[i])
			
		if new_object.has_method('init'):
			new_object.init()
		
		target.add_child(new_object)

	save_game.close()
	
	return true

func delete_game_file() -> bool:
	var save_game = File.new()
	if save_game.file_exists(save_file_path):
		var dir = Directory.new()
		dir.remove(save_file_path)
		return true
	return false
	
