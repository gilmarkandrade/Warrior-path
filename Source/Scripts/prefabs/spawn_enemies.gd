extends Node2D

@export var frequency_spawn:float = 2.0
@export var amount_enemies:int = 5
@export var life_enemie_insert:int = -1
var can_spawn = true
var delay_spawn= Timer.new()

func _ready() -> void:
	add_child(delay_spawn)
	
	
func call_spawn_enemie():

	for i in amount_enemies:
		spawn_enemie()
		delay_spawn.start(frequency_spawn);await delay_spawn.timeout
	call_end_game()
		
func spawn_enemie():
	
	var enemie = preload("res://Enemies/Armored_Axeman/Armored_Axeman.tscn").instantiate()
	get_parent().add_child(enemie)
	enemie.global_position = global_position
	enemie.add_to_group("enemys_spawned")
	if life_enemie_insert >0:
		enemie.life = life_enemie_insert
		
func call_end_game():
	
	if get_tree().get_nodes_in_group("enemys_spawned").size() <=0:
		
		delay_spawn.start(2);await delay_spawn.timeout
		FilterScreen._close_filter()
		delay_spawn.start(1);await delay_spawn.timeout
		get_tree().change_scene_to_file("res://Scenes/interface/end_game.tscn")
		return
	delay_spawn.start(1);await delay_spawn.timeout
	call_end_game()

func _on_area_2d_body_entered(body: Node2D) -> void:
		
	if body.is_in_group("player") and can_spawn:
		can_spawn = false
		call_spawn_enemie()
		
