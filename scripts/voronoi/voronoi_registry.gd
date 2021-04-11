extends Node

var voronois: Array = []

func register_voronoi(index: int, nodes: Array) -> Voronoi:
	for voronoi in voronois:
		if voronoi.index == index:
			return voronoi
	
	var voronoi = Voronoi.new(index, nodes)
	self.voronois.append(voronoi)
	return voronoi
	
func get_by_index(index: int) -> Voronoi:
	for voronoi in self.voronois:
		if voronoi.index == index:
			return voronoi
	return null
