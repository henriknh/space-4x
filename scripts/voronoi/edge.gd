extends Node

class Edge:
	var nodes = []
	var p1 = Vector2.ZERO
	var p2 = Vector2.ZERO
	
	func _init(n: Node2D, p1: Vector2, p2: Vector2):
		self.nodes.append(n)
		self.p1 = p1
		self.p2 = p2
	
	func has_points(p1, p2) -> bool:
		return self.p1 - p1 == Vector2.ZERO and self.p2 - p2 == Vector2.ZERO or self.p1 - p2 == Vector2.ZERO and self.p2 - p1 == Vector2.ZERO
		
	func add_node(n: Node2D) -> void:
		self.nodes.append(n)
	
class EdgeRegistry:
	
	var edges = []
	
	func register_edge(n: Node2D, p1: Vector2, p2: Vector2) -> void:
		for edge in edges:
			if edge.has_points(p1, p2):
				edge.add_node(n)
				return
		edges.append(Edge.new(n, p1, p2))
		
