extends Node

var now: float = 0
var pending: Array = []
var queue: Array = []

var tick: float = 0
var handled_last_tick: int = 0

signal event_queue_changed

func _process(delta):
	now += delta
	tick += delta
	
	if tick < 0.05:
		return
	tick = 0
	
	while pending.size() > 0:
		var item = pending.pop_back()
		if queue.size() == 0:
			queue.append(item)
		else:
			for i in range(queue.size(), 0, -1):
				var curr_time = queue[i-1].time
				if curr_time <= item.time:
					queue.insert(i, item)
					break
	
	handled_last_tick = 0
	while queue.size() > 0 and queue[0].time <= now:
		var item = queue.pop_front()
		handled_last_tick += 1
		if item.parent:
			item.parent.callv("call_deferred", [item.method] + item.args)
	
	emit_signal("event_queue_changed")
	
func add_event(time: float, parent: Spatial, method: String, args: Array = []):
	var item = {
		'time': now + time,
		'parent': parent,
		'method': method,
		'args': args
	}
	call_deferred("_add_event", item)

func _add_event(item):
	pending.append(item)
