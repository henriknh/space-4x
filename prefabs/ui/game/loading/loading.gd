extends VBoxContainer

onready var node_label: Label = $Label
onready var node_progess_bar: ProgressBar = $ProgressBar
func _ready():
	GameState.connect("loading_changed", self, "_update_ui")

func _update_ui():
	visible = GameState.loading
	node_label.text = GameState.loading_label
	node_progess_bar.value = GameState.loading_progress
