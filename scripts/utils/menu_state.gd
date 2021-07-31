extends Node

var _is_over_ui = false
var _over_ui_semaphore = 0
var _menus = []

signal menu_changed

func _ready():
	#Scene.connect("scene_loaded", self, "reset")
	connect("menu_changed", self, "update_visiblity")

func is_over_ui() -> bool:
	if _menus.size() > 1:
		return _menus[_menus.size() - 1].get('block_input') != false
	else:
		return _is_over_ui
	
func set_over_ui(is_over_ui: bool) -> void:
	if is_over_ui:
		_over_ui_semaphore += 1
	else:
		_over_ui_semaphore -= 1
	
	if _over_ui_semaphore < 0:
		_over_ui_semaphore = 0
	
	_is_over_ui = _over_ui_semaphore > 0

func reset() -> void:
	_is_over_ui = false
	for menu in _menus:
		if is_instance_valid(menu):
			menu.queue_free()
	_menus = []
	emit_signal("menu_changed")
	
func push(new_menu: Control) -> void:
	_menus.append(new_menu)
	emit_signal("menu_changed")

func pop() -> void:
	var menu = _menus.pop_back()
	if menu:
		menu.queue_free()
	emit_signal("menu_changed")

func update_visiblity():
	for menu in _menus:
		menu.visible = false if GameState.loading else menu == _menus[_menus.size() - 1]
	
	_over_ui_semaphore = 0
	_is_over_ui = false

func menus_size() -> int:
	return _menus.size()
