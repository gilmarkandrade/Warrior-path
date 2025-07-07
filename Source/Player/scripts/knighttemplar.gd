extends CharacterBody2D
@onready var SpriteAnimation = %AnimSprite
var delay_end_attack = Timer.new()
var cool_down_attack = Timer.new()
var counter_attack:int = 0
const GRAVITY = 980
const SPEED = 200.0
const JUMP_VELOCITY = -400.0
var life = 10.0
var is_dead:bool = false
var can_attack:bool = true
var can_move:bool = true
enum AnimationState {idle,run,attack,Crounched,jump,dead}
var AnimationCurrent = AnimationState.idle

func _ready() -> void:
	
	add_child(delay_end_attack)
	add_child(cool_down_attack)
	delay_end_attack.timeout.connect(_end_attack)
	delay_end_attack.one_shot = true
	
func _physics_process(delta: float) -> void:
	
	_attack_action()
	_Movement(delta)
	_state_machine()
	
func _Movement(delta:float)-> void:
		
	if !is_on_floor():
		velocity.y += GRAVITY* delta
		
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		play_sfx("jump")
		
	var direction := Input.get_axis("Left", "Right")
	if direction!=0:
		if direction == -1:
			SpriteAnimation.flip_h=true
		else:
			SpriteAnimation.flip_h = false
		
		velocity.x = direction * SPEED
		if is_on_floor() and can_move:
			AnimationCurrent = AnimationState.run
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor() and can_move:
			AnimationCurrent = AnimationState.idle
	if !can_move:
		velocity.x = 0.0
	move_and_slide()

func _state_machine():
	
	match AnimationCurrent:
		AnimationState.idle:
			SpriteAnimation.play("Idle")
		AnimationState.run:
			SpriteAnimation.play("Walk0")
		AnimationState.jump:
			SpriteAnimation.play("Idle")
		AnimationState.dead:
			SpriteAnimation.play("Death")
		AnimationState.attack:
			SpriteAnimation.play(str("Attack",counter_attack))
			
func _attack_action():
	
	if Input.is_action_just_pressed("Attack") and can_attack :
		delay_end_attack.start(0.9)
		can_attack = false
		can_move = false
		counter_attack = (counter_attack + 1) % 3 #adiciona e mantem o contador de ataques
		play_sfx(str("Attack",counter_attack))
		AnimationCurrent = AnimationState.attack
		cool_down_attack.start(0.5);await cool_down_attack.timeout
		can_attack = true
		
func _end_attack():
	
	can_attack = true
	can_move = true
	counter_attack = 0
		
func _instance_trigger_damage():
		
	var hitBox = preload("res://Scenes/Prefabs/trigger_damage.tscn").instantiate()
	add_child(hitBox)
	match SpriteAnimation.flip_h:
		true:
			hitBox.position.x = -15
		false:
			hitBox.position.x = 15
	hitBox.delay_destroy = 0.3
	hitBox.group_target = "enemy"
	hitBox.scale=Vector2(1.2,1)
		
		
func hit_effect():
		
	if is_dead == false:
		get_tree().call_group("camera_player","shake_camera",5.0,0.1)
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color(10, 10, 10), 0.1)
		tween.tween_property(self, "modulate", Color(1, 1, 1), 0.1).set_delay(0.1)
		
		
func play_sfx(nameSfx:String):
		
	match nameSfx:
		"Attack0":
			$Sfx_attack.stream = load("res://Audio/sfx/sfx_sword_hit1.wav")
			$Sfx_attack.play()
		"Attack1":
			$Sfx_attack.stream = load("res://Audio/sfx/sfx_sword_hit2.wav")
			$Sfx_attack.play()
		"Attack2":
			$Sfx_attack.stream = load("res://Audio/sfx/sfx_sword_hit2.wav")
			$Sfx_attack.play()
		"damage":
			$Sfx_generals.stream = load("res://Audio/sfx/sfx_damage_player.wav")
			$Sfx_generals.play()
		"jump":
			$Sfx_generals.stream = load("res://Audio/sfx/sfx_jump.wav")
			$Sfx_generals.play()
		"dead":
			$Sfx_death.play()
		
func add_health(value:int):
	
	life +=value
	if life > GameSingleton.max_life_player:
		life =  GameSingleton.max_life_player
	GameSingleton.player_life = life
	get_tree().call_group("hud_player","update_life_hud")
	print(life)
	
func apply_damage(value:int):
		
	hit_effect()
	life -= value
	_death()
	play_sfx("damage")
	get_tree().call_group("hud_player","update_life_hud")
		
func _death():
		
	if life <= 0:
		
		life = 0
		is_dead = true
		AnimationCurrent=AnimationState.dead
		play_sfx("dead")
		set_collision_layer_value(1,false)
		set_collision_mask_value(1,false)
		set_physics_process(false)
	GameSingleton.player_life = life
		
func _on_anim_sprite_frame_changed() -> void:
	
	match SpriteAnimation.animation:
			
		"Attack0":
			if SpriteAnimation.frame == 3:
				_instance_trigger_damage()
		"Attack1":
			if SpriteAnimation.frame == 5:
				_instance_trigger_damage()
		"Attack2":
			if SpriteAnimation.frame == 3 or SpriteAnimation.frame == 7:
				_instance_trigger_damage()
			
