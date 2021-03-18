extends Node2D

var width = 100

func _ready():
	GameState.connect("loading_changed", self, "_listen_for_changed")

func _listen_for_changed():
	if GameState.loading == false:
		for child in get_children():
			if child.has_method("_connect_changed_signals"):
				child._connect_changed_signals()
			if child.has_method("_on_changed"):
				child._on_changed()

func _update_node(node: Line2D, polygon: Array):
	
	polygon = Utils.array_remove_intitial_duplicate(polygon)
	polygon = Utils.polygon_offset(polygon, width / 2)
	polygon = Utils.polygon_add_midpoint_split(polygon)
	
	node.points = polygon
	node.width = width
	node.visible = true
	
	
