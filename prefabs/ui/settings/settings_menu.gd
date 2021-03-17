extends Container

func _ready():
	MenuState.push(self)
	Settings.connect("settings_changed", self, "update_ui")
	self.update_ui()

func update_ui() -> void:
	$VBoxContainer/CheckButtonOrbitCircles.pressed = Settings.get_show_orbit_circles()
	$VBoxContainer/CheckButtonPlanetArea.pressed = Settings.get_show_planet_area()
	$VBoxContainer/CheckButtonFPS.pressed = Settings.get_show_fps()
	$VBoxContainer/CheckButtonVSync.pressed = Settings.get_vsync()
	$VBoxContainer/CheckButtonDebug.pressed = Settings.is_debug()

func _on_show_orbit_circles(show_orbit_circles: bool) -> void:
	Settings.set_show_orbit_circles(show_orbit_circles)
	
func _on_show_planet_area(show_planet_area: bool) -> void:
	Settings.set_show_planet_area(show_planet_area)

func _on_show_fps(show_fps: bool) -> void:
	Settings.set_show_fps(show_fps)

func _on_vsync(vsync: bool) -> void:
	Settings.set_vsync(vsync)
	
func _on_is_debug(debug: bool) -> void:
	Settings.set_debug(debug)
	
func _on_back() -> void:
	MenuState.pop()

