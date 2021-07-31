extends Node

var settings_file_path = "user://settings.json"

enum screen_values {
	windowed,
	fullscreen,
	borderless,
}

var settings = {
	'show_orbit_circles': true,
	'show_planet_area': true,
	'show_fps': false,
	'screen': screen_values.windowed,
	'vsync': false,
	'fps': 0,
	'debug': false
}

signal settings_changed

func _ready():
	if not _load():
		_save()
	
func _after_change():
	_save()
	
	OS.set_use_vsync(settings['vsync'])
	if settings['fps'] == 0:
		Engine.set_target_fps(9001)
	else:
		Engine.set_target_fps(settings['fps'])
	
	if settings['screen'] == screen_values.windowed:
		OS.set_window_fullscreen(false)
		OS.set_window_position(Vector2(0, 0))
		OS.set_window_size(Vector2(1200, 720))
		OS.set_borderless_window(false)
	elif settings['screen'] == screen_values.fullscreen:
		OS.set_borderless_window(false)
		OS.set_window_fullscreen(true)
	elif settings['screen'] == screen_values.borderless:
		OS.set_window_fullscreen(false)
		OS.set_window_position(Vector2(0, 0))
		OS.set_window_size(OS.get_screen_size())
		OS.set_borderless_window(true)
	
	emit_signal("settings_changed")

func set_show_orbit_circles(show_orbit_circles: bool) -> void:
	settings['show_orbit_circles'] = show_orbit_circles
	_after_change()
	
func get_show_orbit_circles() -> bool:
	return settings['show_orbit_circles']

func set_show_planet_area(show_planet_area: bool) -> void:
	settings['show_planet_area'] = show_planet_area
	_after_change()
	
func get_show_planet_area() -> bool:
	return settings['show_planet_area']

func set_screen(value: int) -> void:
	settings['screen'] = value
	_after_change()
	
func get_screen() -> bool:
	return settings['screen']
	
func set_vsync(vsync: bool) -> void:
	settings['vsync'] = vsync
	_after_change()
	
func get_vsync() -> bool:
	return settings['vsync']
	
func set_show_fps(show_fps: bool) -> void:
	settings['show_fps'] = show_fps
	_after_change()
	
func get_show_fps() -> bool:
	return settings['show_fps']

func set_fps(fps: int) -> void:
	settings['fps'] = fps
	_after_change()
	
func get_fps() -> int:
	return settings['fps']

func set_debug(debug: bool) -> void:
	settings['debug'] = debug
	_after_change()
	
func is_debug() -> bool:
	if not OS.is_debug_build():
		return false
	return settings['debug']

func _load() -> bool:
	var load_settings = File.new()
	if not load_settings.file_exists(settings_file_path):
		return false# Error! We don't have a save to load.

	load_settings.open(settings_file_path, File.READ)
	var json: Dictionary = parse_json(load_settings.get_line())
	
	for key in json.keys():
		settings[key] = json[key]
	
	load_settings.close()
	
	_after_change()
	
	return true
	
func _save():
	var save_settings = File.new()
	save_settings.open(settings_file_path, File.WRITE)
	save_settings.store_line(to_json(settings))
	save_settings.close()
