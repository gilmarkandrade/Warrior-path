extends Node2D


func _ready() -> void:
	
	var left_limiter = $Left.global_position.x
	var right_limiter = $Right.global_position.x
	var top_limiter = $Top.global_position.y
	var botton_limiter = $Botton.global_position.y
	get_tree().call_group("camera_player","set_limit_camera",left_limiter,right_limiter,top_limiter,botton_limiter)
	
