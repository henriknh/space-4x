extends Task

class_name CanMine

onready var host: Miner = get_owner()

func _ready():
	if not host:
		breakpoint
	
func run():
	running()
	if (host.titanium + host.dust) < 10:
		success()
	else:
		fail()
