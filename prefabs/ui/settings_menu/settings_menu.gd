extends Container

onready var node_orbit_circles: CheckButton = $VBoxContainer/CheckButtonOrbitCircles
onready var node_planet_area: CheckButton = $VBoxContainer/CheckButtonPlanetArea
onready var node_show_fps: CheckButton = $VBoxContainer/CheckButtonShowFPS
onready var node_screen: MenuButton = $VBoxContainer/MenuButtonScreen
onready var node_vsync: CheckButton = $VBoxContainer/CheckButtonVSync
onready var node_fps: SpinBox = $VBoxContainer/HBoxFPS/SpinBoxFps
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
	node_show_fps.pressed = Settings.get_show_fps()
	
	if Settings.get_screen() == Settings.screen_values.windowed:
		node_screen.text = 'Windowed'
	elif Settings.get_screen() == Settings.screen_values.fullscreen:
		node_screen.text = 'Fullscreen'
	elif Settings.get_screen() == Settings.screen_values.borderless:
		node_screen.text = 'Borderless fullscreen'
	
	node_vsync.pressed = Settings.get_vsync()
	node_fps.value = Settings.get_fps()
	if node_debug:
		node_debug.pressed = Settings.is_debug()

func _on_show_orbit_circles(show_orbit_circles: bool) -> void:
	Settings.set_show_orbit_circles(show_orbit_circles)
	
func _on_show_planet_area(show_planet_area: bool) -> void:
	Settings.set_show_planet_area(show_planet_area)

func _on_show_fps(show_fps: bool) -> void:
	Settings.set_show_fps(show_fps)
	
func _on_set_screen(value: int) -> void:
	Settings.set_screen(value)
	
func _on_vsync(vsync: bool) -> void:
	Settings.set_vsync(vsync)

func _on_fps(value: int):
	Settings.set_fps(value)
	
func _on_is_debug(debug: bool) -> void:
	Settings.set_debug(debug)
	
func _on_back() -> void:
	MenuState.pop()

func _on_screen_about_to_show():
	var menu = node_screen.get_popup()
	menu.clear()
	menu.add_item('Windowed', Settings.screen_values.windowed)
	menu.add_item('Fullscreen', Settings.screen_values.fullscreen)
	menu.add_item('Borderless fullscreen', Settings.screen_values.borderless)
	menu.connect("id_pressed", self, "_on_set_screen")
	menu.popup()
