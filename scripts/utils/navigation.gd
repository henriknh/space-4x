extends Node

class HexAStar:
	extends AStar

	func _compute_cost(u, v):
		return abs(u - v)

	func _estimate_cost(u, v):
		return min(0, abs(u - v) - 1)

var astar = AStar.new()

func create_network():
	for planet_system in get_tree().get_nodes_in_group('PlanetSystem'):
		for tile in planet_system.tiles:
			if not astar.has_point(tile.id):
				astar.add_point(tile.id, (tile as Spatial).global_transform.origin, 1 if not tile.entity else 1000)
				
			for neighbor in tile.neighbors:
				if not astar.has_point(neighbor.id):
					astar.add_point(neighbor.id, (neighbor as Spatial).global_transform.origin, 1 if not tile.entity else 1000)
				
				if not astar.are_points_connected(tile.id, neighbor.id):
					astar.connect_points(tile.id, neighbor.id)
					
#					var st = SurfaceTool.new()
#					st.begin(Mesh.PRIMITIVE_LINE_STRIP)
#					st.add_vertex((tile as Spatial).global_transform.origin)
#					st.add_vertex((neighbor as Spatial).global_transform.origin)
#					var mesh = MeshInstance.new()
#					mesh.mesh = st.commit()
#					get_node("/root/GameScene").add_child(mesh)
	
	for planet_system in get_tree().get_nodes_in_group('PlanetSystem'):
		
		for planet_system_dir in Consts.PLANET_SYSTEM_DIR_ALL:
			var neighbor = planet_system.get_neighbor_in_dir(planet_system_dir)
			if neighbor:
				var planet_system_dir_idx = Consts.PLANET_SYSTEM_DIR_ALL.find(planet_system_dir)
				var tile_dir_1 = Consts.TILE_DIR_ALL[(planet_system_dir_idx - 1 + Consts.PLANET_SYSTEM_DIR_ALL.size()) % Consts.PLANET_SYSTEM_DIR_ALL.size()]
				var tile_dir_2 = Consts.TILE_DIR_ALL[(planet_system_dir_idx - 0 + Consts.PLANET_SYSTEM_DIR_ALL.size()) % Consts.PLANET_SYSTEM_DIR_ALL.size()]
				
				var origin_edge_tiles = []
				for tile in planet_system.tiles:
					if not tile.is_edge:
						continue
					if not tile.has_neighbors_in_dir(tile_dir_1) and not tile.has_neighbors_in_dir(tile_dir_2):
						origin_edge_tiles.append(tile)
				
				var opposite_edge_tiles = []
				for tile in neighbor.tiles:
					if not tile.is_edge:
						continue
					if not tile.has_neighbors_in_dir(-tile_dir_1) and not tile.has_neighbors_in_dir(-tile_dir_2):
						opposite_edge_tiles.append(tile)
			
				for origin_edge_tile in origin_edge_tiles:
					for opposite_edge_tile in opposite_edge_tiles:
						if not astar.are_points_connected(origin_edge_tile.id, opposite_edge_tile.id):
							astar.connect_points(origin_edge_tile.id, opposite_edge_tile.id)
							
#							var st = SurfaceTool.new()
#							st.begin(Mesh.PRIMITIVE_LINE_STRIP)
#							st.add_vertex((origin_edge_tile as Spatial).global_transform.origin)
#							st.add_vertex((opposite_edge_tile as Spatial).global_transform.origin)
#							var mesh = MeshInstance.new()
#							mesh.mesh = st.commit()
#							get_node("/root/GameScene").add_child(mesh)

func get_nav_path(from: int, to: int) -> PoolVector3Array:
	return astar.get_point_path(from, to)

func update_weight(id: int, weight: float):
	astar.set_point_weight_scale(id, weight)
