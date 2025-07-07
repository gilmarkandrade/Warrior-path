extends Control

func _ready() -> void:
	AudioGlobal._play_st("menu")
	FilterScreen._open_filter()

func _on_bt_quit_pressed() -> void:
	get_tree().quit()
