extends CanvasLayer

var timer = null
func _ready():
	$HBoxContainer/PanelContainer.connect("mouse_entered", State, "set_over_ui", [true])
	$HBoxContainer/PanelContainer.connect("mouse_exited", State, "set_over_ui", [false])
	
	timer = Timer.new()
	timer.connect("timeout",self,"_update_ui")
	timer.wait_time = 0.5
	add_child(timer)
	timer.start()

func _update_ui():
	$HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Resources.update_ui()
	$HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Overview.update_ui()


func _on_toggle_overview():
	var overview = $HBoxContainer/PanelContainer/VBoxContainer2/HBoxContainer/Overview
	overview.visible = !overview.visible
	
	if overview.visible:
		overview.update_ui()
