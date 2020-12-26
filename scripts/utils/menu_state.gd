extends Node

var _is_over_ui = false
var _over_ui_semaphore = 0
var _menus = []

func is_over_ui() -> bool:
	if _menus.size() > 0:
		return true
	else: 
		return _is_over_ui
	
func set_over_ui(is_over_ui: bool) -> void:
	if is_over_ui:
		_over_ui_semaphore = _over_ui_semaphore + 1
	else:
		_over_ui_semaphore = _over_ui_semaphore - 1
	
	_is_over_ui = _is_over_ui > 0

func reset_over_ui():
	_is_over_ui = false
	_is_over_ui = 0
	
func push(new_menu: Control):
	_menus.append(new_menu)
	
	if _menus.size() > 1:
		for menu_idx in range(0, _menus.size() - 1):
			_menus[menu_idx].visible = false

func pop():
	var menu = _menus.pop_back()
	if menu:
		menu.queue_free()
		
	if _menus.size() > 0:
		_menus[_menus.size() - 1].visible = true
		
func menus_size() -> int:
	return _menus.size()
