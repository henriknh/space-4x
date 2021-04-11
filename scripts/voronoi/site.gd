extends Node

class_name Site

var edge_registry: EdgeRegistry = EdgeRegistry.new()
var node: Dictionary
var points: Array = []
var convex_hull: Array = []

func _init(node: Dictionary, _points: Array) -> void:
	self.node = node
	for point in _points:
		if not point in self.points:
			self.points.append(point)
	
	self.convex_hull = Geometry.convex_hull_2d(self.points)
	update_edges()
	
func add_point(point: Vector2) -> void:
	if not point in self.points:
		self.points.append(point)
		self.convex_hull = Geometry.convex_hull_2d(self.points)
		update_edges()
	
func remove_point(point: Vector2) -> bool:
	if Utils.array_has(point, self.points):
		self.points.erase(point)
		self.convex_hull = Geometry.convex_hull_2d(self.points)
		update_edges()
		return true
	
	return false
	
func replace_global_point(old_global_point: Vector2, new_global_point: Vector2) -> bool:
	var old_local_point = old_global_point - self.node.position
	var index = Utils.array_idx(old_local_point, self.points)
	if index >= 0:
		self.points[index] = new_global_point - self.node.position
		self.convex_hull = Geometry.convex_hull_2d(self.points)
		update_edges()
		return true
	return false

func get_southern_most_point() -> Vector2:
	var southern_point = -Vector2.INF
	for point in self.convex_hull:
		if point.y > southern_point.y:
			southern_point = point
	return southern_point + self.node.position

func update_edges():
	edge_registry = EdgeRegistry.new()
	
	for i in range(self.convex_hull.size()):
		var j = (i + 1) % self.convex_hull.size()
		edge_registry.register_edge(node, node.position + self.convex_hull[i], node.position + self.convex_hull[j])
