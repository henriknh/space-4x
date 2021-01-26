extends Control

var settings = preload('res://prefabs/ui/settings/settings_menu.tscn')
	
func _ready():
	MenuState.push(self)

func _on_settings():
	get_parent().add_child(settings.instance())

func _on_save():
	StateManager.save()

func _on_main_menu():
	Scene.goto_main_menu()

func _on_quit():
	get_tree().quit()

func _on_back():
	MenuState.pop()
