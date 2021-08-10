extends Task

class_name Mine

onready var host: Miner = get_owner()

var count = 0

const MAX = 100

func run():
	if status == RUNNING:
		count += 1
	
	if count <= MAX:
		running()
	else:
		count = 0
		host.titanium += 1
		if (Random.randi() % 5) == 0:
			host.dust += 1
		success() 
