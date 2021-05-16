extends Node

var corporations = {}

signal corporations_changed

func create(corporation_id: int, is_computer: bool) -> Corporation:
	if not corporations.has(corporation_id):
		corporations[corporation_id] = Corporation.new(corporation_id, is_computer)
	else:
		print('Corporation %d already exists' % corporation_id)
	return corporations[corporation_id]

func get_corporation(corporation_id: int) -> Corporation:
	if corporations.has(corporation_id):
		return corporations[corporation_id]
	else:
		return null

func get_all() -> Array:
	return corporations.values()
