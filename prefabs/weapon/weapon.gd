extends Spatial

class_name Weapon

export var projectile_resource: Resource
export var reload_time: float = 2.0
export var face_target: bool = true
export var facing_speed: float = 2.0
export var target_ships: bool = true
export var target_planets: bool = true

var ready: bool = false
var reload_timer: Timer = Timer.new()
var facing_target: bool = false

func _ready():
	reload_timer.set_wait_time(reload_time)
	reload_timer.connect("timeout", self, "reloaded")
	add_child(reload_timer)
	reload_timer.start()

func update(host, delta):
	if not projectile_resource:
		breakpoint
	
	if not is_instance_valid(host.target):
		host.target = null
	
	if host.target and host.target.corporation_id == 0:
		host.target = null
		
	if host.target and host.target.corporation_id == host.corporation_id:
		host.target = null
		
	if host.target and face_target:
		var target_position = host.target.global_transform.origin
		var new_transform = host.global_transform.looking_at(target_position, Vector3.UP)
		host.global_transform  = host.global_transform.interpolate_with(new_transform, facing_speed * delta)
		facing_target = host.global_transform.is_equal_approx(new_transform)
	
	if can_shoot(host):
		ready = false
		shoot(host)
	
	if not ready and reload_timer.is_stopped():
		reload_timer.start()
	
	return host.target != null

func shoot(host):
	var projectile = projectile_resource.instance()
	projectile.global_transform.origin = global_transform.origin
	get_node('/root/GameScene').add_child(projectile)
	projectile.set_host(host)

func reloaded():
	ready = true

func can_shoot(host) -> bool:
	if ready and host.target:
		if not target_ships and host.target is Ship:
			return false
		if not target_planets and host.target is Planet:
			return false
		
		if face_target:
			return facing_target
		else:
			return true
	return false
