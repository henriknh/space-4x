extends VBoxContainer

onready var node_label: Label = $Label

func set_label(label: String):
	node_label.text = label
