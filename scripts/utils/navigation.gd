extends Node

class CustomAStar:
	extends AStar
	
	var tiles = {}
	
	func _compute_cost(from: int, to: int):
		var from_point = get_point_position(from)
		var from_tile: Tile = tiles[from]
		var to_point = get_point_position(to)
		var to_tile: Tile = tiles[to]
		if to_tile.entity:
			return null
		var cost = from_point.distance_to(to_point)
		if to_tile.corporation_id != from_tile.corporation_id:
			cost *= 10
		return cost
	
	func _estimate_cost(from: int, to: int):
		return _compute_cost(from, to)
		
	func add_tile(tile: Tile):
		tiles[tile.id] = tile
		add_point(tile.id, (tile as Spatial).global_transform.origin, 1 if not tile.entity else 1000)
		
	func listen_to_tiles_changes():
		for tile in tiles.values():
			tile.connect("entity_changed", self, "tile_changed", [tile])
			tile_changed(tile)
	
	func tile_changed(tile: Tile):
		set_point_disabled(tile.id, tile.entity is Planet)

var astar: CustomAStar

func create_network():
	astar = CustomAStar.new()
	
	for tile in get_tree().get_nodes_in_group('Tile'):
		
		if not astar.has_point(tile.id):
			astar.add_tile(tile)
			
		for neighbor in tile.neighbors:
			if not astar.has_point(neighbor.id):
				astar.add_tile(neighbor)
			
			if not astar.are_points_connected(tile.id, neighbor.id):
				astar.connect_points(tile.id, neighbor.id)
				
				var st = SurfaceTool.new()
				st.begin(Mesh.PRIMITIVE_LINE_STRIP)
				st.add_vertex((tile as Spatial).global_transform.origin)
				st.add_vertex((neighbor as Spatial).global_transform.origin)
				var mesh = MeshInstance.new()
				mesh.mesh = st.commit()
				var material = SpatialMaterial.new()
				material.albedo_color = Color(1,0,0,1)
				mesh.material_override = material
				get_node("/root/GameScene").add_child(mesh)
	
	for planet_system in []: #().get_nodes_in_group('PlanetSystem'):
		
		for planet_system_dir in Consts.PLANET_SYSTEM_DIR_ALL:
			var neighbor = planet_system.get_neighbor_in_dir(planet_system_dir)
			if neighbor:
				var planet_system_dir_idx = Consts.PLANET_SYSTEM_DIR_ALL.find(planet_system_dir)
				var tile_dir_1 = Consts.TILE_DIR_ALL[(planet_system_dir_idx + 1 + Consts.PLANET_SYSTEM_DIR_ALL.size()) % Consts.PLANET_SYSTEM_DIR_ALL.size()]
				var tile_dir_2 = Consts.TILE_DIR_ALL[(planet_system_dir_idx - 0 + Consts.PLANET_SYSTEM_DIR_ALL.size()) % Consts.PLANET_SYSTEM_DIR_ALL.size()]
				
				var origin_edge_tiles = []
				for tile in planet_system.tiles:
					if not tile.is_edge:
						continue
					if not tile.has_neighbor_in_dir(tile_dir_1) and not tile.has_neighbor_in_dir(tile_dir_2):
						origin_edge_tiles.append(tile)
				
				var opposite_edge_tiles = []
				for tile in neighbor.tiles:
					if not tile.is_edge:
						continue
					if not tile.has_neighbor_in_dir(-tile_dir_1) and not tile.has_neighbor_in_dir(-tile_dir_2):
						opposite_edge_tiles.append(tile)
			
				for origin_edge_tile in origin_edge_tiles:
					for opposite_edge_tile in opposite_edge_tiles:
						if not astar.are_points_connected(origin_edge_tile.id, opposite_edge_tile.id):
							astar.connect_points(origin_edge_tile.id, opposite_edge_tile.id)
							
#								var st = SurfaceTool.new()
#								st.begin(Mesh.PRIMITIVE_LINE_STRIP)
#								st.add_vertex((origin_edge_tile as Spatial).global_transform.origin)
#								st.add_vertex((opposite_edge_tile as Spatial).global_transform.origin)
#								var mesh = MeshInstance.new()
#								mesh.mesh = st.commit()
#								var material = SpatialMaterial.new()
#								material.albedo_color = Color(1,0,0,1)
#								mesh.material_override = material
#								get_node("/root/GameScene").add_child(mesh)

	astar.listen_to_tiles_changes()

func get_nav_path(from: Entity, to: Entity) -> PoolVector3Array:
	var from_id = astar.get_closest_point(from.translation)
	var to_id = astar.get_closest_point(to.translation)
	return astar.get_point_path(from_id, to_id)
