extends Container

onready var node_orbit_circles: CheckButton = $VBoxContainer/CheckButtonOrbitCircles
onready var node_planet_area: CheckButton = $VBoxContainer/CheckButtonPlanetArea
onready var node_fps: CheckButton = $VBoxContainer/CheckButtonFPS
onready var node_vsync: CheckButton = $VBoxContainer/CheckButtonVSync
onready var node_debug: CheckButton = $VBoxContainer/CheckButtonDebug

func _ready():
	MenuState.push(self)

	if not OS.is_debug_build():
		node_debug.queue_free()
	
	Settings.connect("settings_changed", self, "update_ui")
	self.update_ui()

func update_ui() -> void:
	node_orbit_circles.pressed = Settings.get_show_orbit_circles()
	node_planet_area.pressed = Settings.get_show_planet_area()
	node_fps.pressed = Settings.get_show_fps()
	node_vsync.pressed = Settings.get_vsync()
	if node_debug:
		node_debug.pressed = Settings.is_debug()

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

