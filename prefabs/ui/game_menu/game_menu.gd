extends CanvasLayer

var settings = preload('res://prefabs/ui/settings/settings.tscn')

func _on_settings():
	queue_free()
	get_parent().add_child(settings.instance())

func _on_save():
	StateManager.save_game()

func _on_main_menu():
	Scene.goto_scene(Enums.scenes.main_menu)

func _on_quit():
	get_tree().quit()

func _on_back():
	queue_free()
