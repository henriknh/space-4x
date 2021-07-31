extends State

export var speed: float = 100

func exit():
	host.target = null
	
func update(delta):
	if host.parent == host.target:
		return true
	
	ui_progress += delta * speed
	
	if ui_progress > 100:
		var path = Nav.get_nav_path(host, host.target)
		if path.size() > 0:
			host.translation = path[1]
			ui_progress = 0
		else:
			print('Error: Move did not have a path')
			return true
	
	return 
