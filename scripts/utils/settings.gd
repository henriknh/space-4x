extends Node

var settings_file_path = "user://settings.conf"

var settings = {
	'show_orbit_circles': false,
	'show_planet_area': false,
	'is_debug': false
}

signal settings_changed

func _ready():
	if not _load():
		_save()
	
func _after_change():
	_save()
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

func set_is_debug(is_debug: bool) -> void:
	settings['is_debug'] = is_debug
	_after_change()
	
func get_is_debug() -> bool:
	return settings['is_debug']

func _load() -> bool:
	var load_settings = File.new()
	if not load_settings.file_exists(settings_file_path):
		return false# Error! We don't have a save to load.

	load_settings.open(settings_file_path, File.READ)
	settings = parse_json(load_settings.get_line())
	
	load_settings.close()
	
	return true
	
func _save():
	var save_settings = File.new()
	save_settings.open(settings_file_path, File.WRITE)
	save_settings.store_line(to_json(settings))
	save_settings.close()
