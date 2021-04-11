extends Node

class_name EdgeRegistry

var edges = []

func register_edge(n: Node2D, p1: Vector2, p2: Vector2) -> Edge:
	for edge in edges:
		if edge.has_points(p1, p2):
			edge.add_node(n)
			return edge
	var new_edge = Edge.new(n, p1, p2)
	edges.append(new_edge)
	return new_edge
	
