extends Camera2D


func shake_camera(strength := 10.0, duration := 0.2):
	
	if !GameSingleton.can_use_camera_shake:
		return
	var tween = get_tree().create_tween()
	var original_position = offset
	var shake_counter = 4
	var interval = duration / shake_counter
	for i in range(shake_counter):
		var random_offset = Vector2(randf_range(-strength, strength), randf_range(-strength, strength))
		tween.tween_property(self, "offset", original_position + random_offset, interval * 0.5)
		tween.tween_property(self, "offset", original_position, interval * 0.5)


func set_limit_camera(left,right,top,botton):
	
	limit_left = left
	limit_right = right
	limit_top = top
	limit_bottom = botton
