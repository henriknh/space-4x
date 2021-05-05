extends Spatial

var is_pivot: bool = false

var pivot: Vector3 = Vector3(15, 0, 0)

var move_dir: Vector3 = Vector3.ZERO
var move_keys_pressed = {
	KEY_A: false,
	KEY_D: false,
	KEY_W: false,
	KEY_S: false
}
var move_dir_keys: Vector2 = Vector2.ZERO
var move_dir_mouse: Vector2 = Vector2.ZERO
var screen_edge_size : int = 25

var zoom_step: int = 0
var zoom: int = 0
var min_zoom: int = 1
var max_zoom: int = 10
var can_overview: bool = false
var can_overview_timer: float = 0

func _ready():
	zoom_step = 5
	_set_zoom_by_step()

func _input(event):
	if event is InputEventKey:
		if event.scancode == KEY_A:
			move_keys_pressed[KEY_A] = event.pressed
		if event.scancode == KEY_D:
			move_keys_pressed[KEY_D] = event.pressed
		if event.scancode == KEY_W:
			move_keys_pressed[KEY_W] = event.pressed
		if event.scancode == KEY_S:
			move_keys_pressed[KEY_S] = event.pressed
			
	if move_keys_pressed[KEY_A] and not move_keys_pressed[KEY_D]:
		move_dir_keys.x = -1
	elif not move_keys_pressed[KEY_A] and move_keys_pressed[KEY_D]:
		move_dir_keys.x = 1
	else:
		move_dir_keys.x = 0
			
	if move_keys_pressed[KEY_W] and not move_keys_pressed[KEY_S]:
		move_dir_keys.y = -1
	elif not move_keys_pressed[KEY_W] and move_keys_pressed[KEY_S]:
		move_dir_keys.y = 1
	else:
		move_dir_keys.y = 0
		
	if event is InputEventMouseMotion:
		if is_pivot:
			pivot -= Vector3(event.relative.y, event.relative.x, 0)
			pivot.x = clamp(pivot.x, 10, 80)
		else:
			var view_size: Vector2 = get_viewport().get_visible_rect().size
			var mouse_pos: Vector2 = event.position
			
			if mouse_pos.x < screen_edge_size:
				move_dir_mouse.x = -1
			elif view_size.x - screen_edge_size < mouse_pos.x:
				move_dir_mouse.x = 1
			else:
				move_dir_mouse.x = 0
			
			if mouse_pos.y < screen_edge_size:
				move_dir_mouse.y = -1
			elif view_size.y - screen_edge_size < mouse_pos.y:
				move_dir_mouse.y = 1
			else:
				move_dir_mouse.y = 0
	
	var _move_dir: Vector2 = Vector2(sign(move_dir_keys.x + move_dir_mouse.x), sign(move_dir_keys.y + move_dir_mouse.y))
	_move_dir = _move_dir.rotated(-deg2rad(pivot.y))
	move_dir = Vector3(_move_dir.x, 0, _move_dir.y)
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:
			if event.pressed and not event.is_echo():
				var direction = (-1 if event.button_index == BUTTON_WHEEL_UP else 0) + (1 if event.button_index == BUTTON_WHEEL_DOWN else 0)
				
				if direction > 0 and zoom_step + direction > max_zoom and can_overview:
					zoom_step = 20
					GameState.set_planet_system(null)
					_set_zoom_by_step()
				else:
					if not GameState.curr_planet_system:
						var closest_planet_system = null
						var closest_dist = INF
						
						for planet_system in get_node("/root/GameScene/Galaxy").planet_systems:
							var dist = translation.distance_to(planet_system.translation)
							if dist < closest_dist:
								closest_dist = dist
								closest_planet_system = planet_system
						
						GameState.set_planet_system(closest_planet_system)
					
					zoom_step += direction
					zoom_step = clamp(zoom_step, min_zoom, max_zoom) as int
					_set_zoom_by_step()
		if event.button_index == BUTTON_MIDDLE:
			is_pivot = event.pressed

func _process(delta):
	
	if zoom_step >= max_zoom:
		can_overview_timer += delta
	else:
		can_overview_timer = 0
	
	can_overview = can_overview_timer > 0.3
	
func is_overview() -> bool:
	return zoom_step > max_zoom

func _set_zoom_by_step():
	zoom = pow(zoom_step, 2) as int + 2

func get_move_dir() -> Vector3:
	return move_dir
	
func get_zoom() -> int:
	return zoom
