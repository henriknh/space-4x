extends State

func exit():
	host.target = null
	
func update(delta):
	if host.parent == host.target:
		return true
	
	ui_progress += (delta / process_speed)
	
	if ui_progress >= 1:
		var path = Nav.get_nav_path(host, host.target)
		if path.size() > 1:
			host.translation = path[1]
			ui_progress = 0
		else:
			return true
	
	return 
