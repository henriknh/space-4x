extends Task

class_name Deliver

onready var host: Miner = get_owner()

var count = 0

const MAX = 100

func run():
	running()
	
	var corporation = host.get_corporation()
	
	corporation.resource_titanium += host.titanium
	corporation.resource_dust += host.dust
	
	host.titanium = 0
	host.dust = 0
	
	success()
