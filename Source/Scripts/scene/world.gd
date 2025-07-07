extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	FilterScreen._open_filter()
	AudioGlobal._play_st("game")
