extends State

class_name ScanForEnemiesState

export var weapon_range: int = 1
export var on_target_found_state: NodePath

var tiles = []

func _ready():
	if not on_target_found_state:
		breakpoint

func enter():
	host.connect('ship_arrive', self, 'calc_area')
	host.connect('parent_changed', self, 'calc_area')
	calc_area()

func exit():
	host.disconnect('ship_arrive', self, 'calc_area')
	host.disconnect('parent_changed', self, 'calc_area')
	
func update(_delta):
	if host.target:
		return on_target_found_state

func calc_area():
	
	for tile in tiles:
		if is_instance_valid(tile):
			tile.disconnect("ship_changed", self, "scan_tile")
	
	tiles = []
	
	if host.parent:
		tiles.append(host.parent)
	
	for _r in range(weapon_range):
		var pending = []
		for t in tiles:
			for n in t.neighbors:
				pending.append(n)
		for p in pending:
			if not p in tiles:
				tiles.append(p)
	
	for tile in tiles:
		scan_tile(tile)
		tile.connect("ship_changed", self, "scan_tile", [tile])

func scan_tile(tile):
	for ship in tile.ships:
		if not host.target and ship.corporation_id > 0 and ship.corporation_id != host.corporation_id:
			host.target = ship
	if not host.target and tile.entity and is_instance_valid(tile.entity) and tile.entity.corporation_id > 0 and tile.entity.corporation_id != host.corporation_id and tile.entity.health > 0:
		host.target = tile.entity
