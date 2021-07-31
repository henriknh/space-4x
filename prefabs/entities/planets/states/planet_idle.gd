extends State

export var speed = 5

var progress = 0
var corporation = null

func enter():
	corporation = host.get_corporation()

func exit():
	corporation = null
	progress = 0

func update(delta):
	
	if corporation:
		progress += delta * speed
		if progress > 100:
			corporation.resource_titanium += 2
			progress = 0

	return
