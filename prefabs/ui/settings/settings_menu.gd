extends Container

func _ready():
	MenuState.push(self)
	Settings.connect("settings_changed", self, "update_ui")
	update_ui()

func update_ui():
	$VBoxContainer/CheckButtonOrbitCircles.pressed = Settings.get_show_orbit_circles()
	$VBoxContainer/CheckButtonPlanetArea.pressed = Settings.get_show_planet_area()
	$VBoxContainer/CheckButtonFPS.pressed = Settings.get_is_debug()

func _on_show_orbit_circles(show_orbit_circles: bool) -> void:
	Settings.set_show_orbit_circles(show_orbit_circles)
	
func _on_show_planet_area(show_planet_area: bool) -> void:
	Settings.set_show_planet_area(show_planet_area)
	
func _on_is_debug(is_debug: bool) -> void:
	Settings.set_is_debug(is_debug)
	
func _on_back():
	MenuState.pop()
