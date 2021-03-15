extends VBoxContainer

func _ready():
	GameState.connect("loading_changed", self, "_update_ui")

func _update_ui():
	visible = GameState.loading
	$Label.text = GameState.loading_label
	$ProgressBar.value = GameState.loading_progress
