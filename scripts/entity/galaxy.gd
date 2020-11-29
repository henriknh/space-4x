extends entity

class_name galaxy

func create():
	set_name(NameGenerator.get_name_galaxy())
	set_indestructible(true)
	visible = false
	
func _ready():
	# Make node clickable with mouse
	input_pickable = true 
	
	$EntityGUI/Label.text = get_name()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		var button_event = event as InputEventMouseButton
		if button_event.pressed and button_event.button_index == BUTTON_LEFT:
			State.set_star_system(get_star_system())
