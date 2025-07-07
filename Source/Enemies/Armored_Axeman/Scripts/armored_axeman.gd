extends CharacterBody2D

@onready var SpriteAnimation = %AnimSprite
@onready var VisibilityNotify = $VisibleOnScreenNotifier2D
@onready var raycast_wall = %RayCastWall

enum animation_state {idle,run,attack,Crounched,jump,dead}
var animation_current = animation_state.idle
const GRAVITY:float = 980.0
const SPEED:float = 100.0
const JUMP_VELOCITY:float = -300.0
var life:int = 3
var player_in_range:bool = false
var can_attack:bool = true
var can_move:bool = true
var is_dead:bool = false
var on_screen:bool = false
var delay_attack = Timer.new()

func _ready() -> void:
	
	add_child(delay_attack)
	VisibilityNotify.connect("screen_entered",_check_visibility)
	VisibilityNotify.connect("screen_exited",_check_visibility)
	_check_visibility()
	
func _physics_process(delta: float) -> void:
	#_check_visibility()
	_process_attack()
	_Movement(delta)
	_process_jump_over_wall()
	_state_machine()
	
func _Movement(delta:float)->void:
		
	var PlayerPosition = get_player_position()
	var distance = position.distance_to(PlayerPosition)
	var x_diff = PlayerPosition.x - global_position.x
	var y_diff = PlayerPosition.y - global_position.y
		
	if !is_on_floor():
		velocity.y +=  GRAVITY* delta
		
	if can_move == false or is_dead :
		velocity.x = 0.0
		move_and_slide()
		return
		
	if distance >20 and abs(x_diff)>2   and GameSingleton.player_life>0:
		if PlayerPosition.x > global_position.x :
			velocity.x = SPEED
			SpriteAnimation.flip_h = false
			animation_current=animation_state.run
			raycast_wall.target_position.x = 20
		else:
			velocity.x = -SPEED
			SpriteAnimation.flip_h = true
			animation_current=animation_state.run
			raycast_wall.target_position.x = -20
	else:
		velocity = Vector2.ZERO
		if is_dead == false:
			animation_current=animation_state.idle
	move_and_slide()
		
  # ajuste conforme a sua gravidade
	
func _process_jump_over_wall():
	
	if raycast_wall.is_colliding():
		var collider =raycast_wall.get_collider()
		if collider.is_in_group("wall") and is_on_floor() and can_move:
				velocity.y = JUMP_VELOCITY
			
			
func _process_attack():
	
	if GameSingleton.player_life <= 0:
		return
		
	if player_in_range == true and can_attack == true and is_dead == false:
		can_move = false
		can_attack = false
		animation_current = animation_state.attack
		play_sfx("Attack")
		delay_attack.start(1);await delay_attack.timeout
		can_move = true
		delay_attack.start(0.5);await delay_attack.timeout
		can_attack = true
		
func _state_machine():
	
	if is_dead:
		animation_current = animation_state.dead
		
	match animation_current:
		
		animation_state.idle:
			SpriteAnimation.play("Idle")
			
		animation_state.run:
			SpriteAnimation.play("Walk")
			
		animation_state.jump:
			SpriteAnimation.play("Idle")
			
		animation_state.attack:
			SpriteAnimation.play("Attack0")
		
		animation_state.dead:
			SpriteAnimation.play("Death")
			
func get_player_position():
		
	var objects = get_tree().get_nodes_in_group("player")
	if objects.size() > 0:
		return objects[0].global_position
	return global_position
		
func _on_anim_sprite_frame_changed() -> void:
	
	if SpriteAnimation == null:
		return
		
	if SpriteAnimation.animation == "Attack0":
		if SpriteAnimation.frame == 4:
			_instance_trigger_damage(SpriteAnimation.flip_h)
			
func _instance_trigger_damage(side:bool):
	
	var hitBox = preload("res://Scenes/Prefabs/trigger_damage.tscn").instantiate()
	add_child(hitBox)
	match side:
		true:
			hitBox.position.x = -10
		false:
			hitBox.position.x = 10
	hitBox.delay_destroy = 0.2
	hitBox.group_target = "player"
		
func _death():
	
	if life <= 0:
		life = 0
		is_dead = true
		SpriteAnimation.z_index = -1
		animation_current=animation_state.dead
		set_collision_layer_value(2,false)
		set_collision_mask_value(2,false)
		play_sfx("dead")
		get_tree().create_timer(0.1).timeout
		set_physics_process(false)
		_state_machine()
		spawn_pickup()
		if is_in_group("enemys_spawned"):
			remove_from_group("enemys_spawned")
			
func apply_damage(value:int):
	if is_dead == false:
		_hit_effect()
		life -= value
		_death()
	
	
func _hit_effect():
	
	if is_dead == false:
		get_tree().call_group("camera_player","shake_camera",2.0,0.1)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(10, 10, 10), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1).set_delay(0.1)
	
func play_sfx(nameSfx:String):
	
	if is_dead == false:
		match nameSfx:
			"Attack":
				$Sfx.stream = load("res://Audio/sfx/sfx_axe_effect.wav")
				$Sfx.play()
				
			"dead":
				randomize()
				var value_pitch = randf_range(0.9,1.2)
				$Sfx.pitch_scale = value_pitch
				$Sfx.stream = load("res://Audio/sfx/sfs_death_enemie.wav")
				$Sfx.play()
			
func spawn_pickup():
	randomize()
	var canSpawn = randi_range(0,2)
	if canSpawn > 1:
		var pickup = preload("res://Scenes/Prefabs/health_pickup.tscn").instantiate()
		get_parent().call_deferred("add_child",pickup)
		pickup.global_position = global_position
		
	
func _on_range_area_body_entered(body: Node2D) -> void:
		
	if body.is_in_group("player"):
		player_in_range = true
		
func _on_range_area_body_exited(body: Node2D) -> void:
		
	if body.is_in_group("player"):
		player_in_range = false

func _check_visibility():
	
	if is_dead == false:
		on_screen = VisibilityNotify.is_on_screen()
		set_physics_process(on_screen)
