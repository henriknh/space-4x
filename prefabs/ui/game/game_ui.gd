extends CanvasLayer

var game_menu_prefab = preload('res://prefabs/ui/game_menu/game_menu.tscn')

func _ready():
	$HBoxContainer/PanelContainer.connect("mouse_entered", MenuState, "set_over_ui", [true])
	$HBoxContainer/PanelContainer.connect("mouse_exited", MenuState, "set_over_ui", [false])
	
	var timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	timer.wait_time = 0.5
	add_child(timer)
	timer.start()

func _input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		if MenuState.menus_size() == 0:
			add_child(game_menu_prefab.instance())
		else:
			MenuState.pop()
	
func _update_ui():
	$HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Resources.update_ui()
	$HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Overview.update_ui()

func _on_toggle_overview():
	var overview = $HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Overview
	overview.visible = !overview.visible
	
	if overview.visible:
		overview.update_ui()
