extends Node

var _is_over_ui = false
var _over_ui_semaphore = 0
var _menus = []

signal menu_changed

func is_over_ui() -> bool:
	if _menus.size() > 1:
		return _menus[_menus.size() - 1].get('block_input') != false
	else: 
		return _is_over_ui
	
func set_over_ui(is_over_ui: bool) -> void:
	if is_over_ui:
		_over_ui_semaphore = _over_ui_semaphore + 1
	else:
		_over_ui_semaphore = _over_ui_semaphore - 1
	
	_is_over_ui = _over_ui_semaphore > 0

func reset() -> void:
	_is_over_ui = false
	_is_over_ui = 0
	for menu in _menus:
		if menu:
			menu.queue_free()
	_menus = []
	emit_signal("menu_changed")
	
func push(new_menu: Control) -> void:
	_menus.append(new_menu)
	if _menus.size() > 1:
		for menu_idx in range(0, _menus.size() - 1):
			_menus[menu_idx].visible = false
	emit_signal("menu_changed")

func pop() -> void:
	var menu = _menus.pop_back()
	if menu:
		menu.queue_free()
		
	if _menus.size() > 0:
		_menus[_menus.size() - 1].visible = true
	emit_signal("menu_changed")
	GameState.emit_signal("update_ui")
		
func menus_size() -> int:
	return _menus.size()
