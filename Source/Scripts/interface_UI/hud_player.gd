extends Control

@onready var icon1 = %heart_icon1
@onready var icon2 = %heart_icon2
@onready var icon3 = %heart_icon3
@onready var icon4 = %heart_icon4
@onready var icon5 = %heart_icon5
@onready var game_over = %GameOver
@onready var label = %LabelInfo
@onready var pause_panel = %pause
var is_game_over = false


	
func update_life_hud():
	
	var total_life = GameSingleton.player_life  # valor de 0 a 10
	var icons = [icon1, icon2, icon3, icon4, icon5]
	for i in range(5):
		var heart_value = clamp(total_life - (i * 2), 0, 2)
		icons[i].set_heart_state(heart_value)
	if GameSingleton.player_life<=0:
		_start_game_over()
	
func _start_game_over():
	
	game_over.visible = true
	show_text_typing("Pressione qualquer botão")
	#set_process_input(true)
	
func show_text_typing(text: String):
	label.bbcode_text = text
	label.visible_characters = 0
	var char_count = text.length()
	var tween = get_tree().create_tween()
	tween.tween_property(label, "visible_characters", char_count, 0.05 * char_count)
	
func _input(event: InputEvent) -> void:
	
	if event is InputEventKey:
		if is_game_over :
			GameSingleton.reset_parameters()
			get_tree().change_scene_to_file("res://world_0.tscn")
	
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
		pause_panel.visible = get_tree().paused
