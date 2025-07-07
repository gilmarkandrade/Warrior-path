extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	AudioGlobal._play_st("menu")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_bt_play_pressed() -> void:
	$%BtPlay.disabled = true
	$%BtPlayTeste.disabled = true
	$sfx_button.play()
	FilterScreen._close_filter()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/Level/world.tscn")


func _on_bt_play_teste_pressed() -> void:
	
	$%BtPlay.disabled = true
	$%BtPlayTeste.disabled = true
	$sfx_button.play()
	FilterScreen._close_filter()
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://Scenes/Level/world_teste.tscn")


func _on_bt_playquit_pressed() -> void:
	
	get_tree().quit()

func volume_percent_to_db(value: float) -> float:
	return lerp(-80.0, 0.0, value / 100.0)
	
func _on_h_slider_value_changed(value: float) -> void:
	
	var db = volume_percent_to_db(value)
	var bus_index = AudioServer.get_bus_index("soundeffects")
	AudioServer.set_bus_volume_db(bus_index, db)


func _on_st_slider_value_changed(value: float) -> void:
	var db = volume_percent_to_db(value)
	var bus_index = AudioServer.get_bus_index("soundtrack")
	AudioServer.set_bus_volume_db(bus_index, db)
