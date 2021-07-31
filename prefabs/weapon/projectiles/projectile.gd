extends Spatial

class_name Projectile

export var damage: int = 1 
var target: Entity

func set_host(_host: Entity) -> void:
	pass

func inflict_damage():
	target.health -= damage
	
	if target.health <= 0:
		target.queue_free()
