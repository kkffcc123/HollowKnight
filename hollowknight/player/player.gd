extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $SpriteArea2D/Sprite2D
@onready var sprite_area_2d: Area2D = $SpriteArea2D
@onready var attack_timer: Timer = $AttackTimer
@onready var animation_gather: Node2D = $AnimationGather
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var player_hurt_collision: CollisionPolygon2D = $SpriteArea2D/PlayerHurtArea2D/PlayerHurtCollision

enum State{
	NORMAL,
	DASH,
	HORIZONGTAL_ATTACK,
	UP_ATTACK,
	DOWN_ATTACK,
	ATTACK_JUMP,
	HURT_STATE,
}

var currcent_state = State.NORMAL

var can_dash : bool = false
var is_dashing : bool = false
var dash_gravity = 0
#var dash_cd = 4.0
var dash_speed = 200
var dash_direciton : Vector2 = Vector2.ZERO

var gravity = 300
var horizontal_move_speed = 150
var horizontal_move_direciton : Vector2 = Vector2.ZERO
var deceleraion_speed = 30

var jump_height = 200
var lower_jump = 4
var attack_jump_height = 200

var can_double_jump : bool = false
var double_jump_height = 150
var is_double_jumping : bool = false

var horizontal_attack_number : int = 0

var black_dash_is_ready : bool = false
var is_black_dashing : bool = false

var hurt_distance : int = 200
var player_shining : bool = false

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	#操纵不同状态下所作用的重力
	if is_dashing:
		velocity.y = dash_gravity
	elif not is_dashing:
		velocity.y += gravity * delta
	
	#切换状态，match只匹配一次，之后便退出match，执行match语句后的内容
	match currcent_state:
		State.NORMAL:
			normal_physics_process(delta)
		State.DASH:
			dash_physics_process(delta)
		State.HORIZONGTAL_ATTACK:
			horizontal_attack_physics_process(delta)
		State.UP_ATTACK:
			up_attack_physics_process(delta)
		State.DOWN_ATTACK:
			down_attack_physics_process(delta)
		State.ATTACK_JUMP:
			attack_jump_physics_process(delta)
		State.HURT_STATE:
			hurt_physics_process(delta)

	move_and_slide()
	
func normal_physics_process(delta: float) -> void:
	dash_and_double_jump_refresh()
	horizontal_move()
	jump_logic(delta)
	set_animation()
	change_state()

func dash_physics_process(delta: float) -> void:
	can_dash = false
	
	dash_direciton.x = horizontal_move_direciton.x
	if dash_direciton.x == 0:
		dash_direciton.x = -1 if sprite_area_2d.scale.x == -1 else 1
	
	black_dash_is_ready = animation_gather.black_dash_is_ready
	
	velocity.x = dash_direciton.x * dash_speed
	
	if black_dash_is_ready == true:
		is_black_dashing = true
		animation_player.play("black_dash")
		
		if is_black_dashing:
			player_hurt_collision.disabled = true
		
		await animation_player.animation_finished
		animation_gather.play_gather_animation()
		is_black_dashing = false
		is_dashing = false
		if invincible_timer.is_stopped():
			player_hurt_collision.disabled = false
		currcent_state = State.NORMAL
	else:
		animation_player.play("dash")
		await animation_player.animation_finished
		is_dashing = false
		currcent_state = State.NORMAL
	
func horizontal_attack_physics_process(delta: float) -> void:
	if horizontal_attack_number == 0:
		animation_player.play("horizontal_attack_1")
		await animation_player.animation_finished
	else:
		animation_player.play("horizontal_attack_2")
		await animation_player.animation_finished
		
	currcent_state = State.NORMAL
		
func up_attack_physics_process(delta: float) -> void:
	animation_player.play("up_attack")
	await animation_player.animation_finished
	currcent_state = State.NORMAL
	
func down_attack_physics_process(delta: float) -> void:
	animation_player.play("down_attack")
	await animation_player.animation_finished
	currcent_state = State.NORMAL
	
func attack_jump_physics_process(delta : float) -> void:
	pass
	
func hurt_physics_process(delta : float) -> void:
	if invincible_timer.is_stopped() == true:
		invincible_timer.start()
		player_hurt_collision.disabled = true
		while player_shining:
			sprite_2d.visible = false
			await(get_tree().create_timer(0.05).timeout)
			sprite_2d.visible = true
			await(get_tree().create_timer(0.05).timeout)
	
	animation_player.play("hurt")
	
	if sprite_area_2d.scale.x == -1:
		velocity.x = hurt_distance
	else:
		velocity.x = -hurt_distance
	
	await animation_player.animation_finished
	currcent_state = State.NORMAL

func change_state() -> void:
	if Input.is_action_just_pressed("dash") and can_dash == true:
		is_dashing = true
		currcent_state = State.DASH
	if Input.is_action_just_pressed("attack") and attack_timer.is_stopped():
		if Input.is_action_pressed("move_down") and not is_on_floor() and attack_timer.is_stopped():
			attack_timer.start()
			currcent_state = State.DOWN_ATTACK
		elif Input.is_action_pressed("move_up") and attack_timer.is_stopped():
			attack_timer.start()
			currcent_state = State.UP_ATTACK
		else:
			attack_timer.start()
			horizontal_attack_number = randi_range(0,1)
			currcent_state = State.HORIZONGTAL_ATTACK
	
func dash_and_double_jump_refresh() -> void:
	if is_on_floor():
		can_dash = true
		can_double_jump = true

func horizontal_move() -> void:
	horizontal_move_direciton.x = Input.get_axis("move_left","move_right")
	if horizontal_move_direciton.x:
		velocity.x = horizontal_move_direciton.x * horizontal_move_speed
	else:
		velocity.x = 0
		
func jump_logic(delta : float) -> void:
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -jump_height
		elif can_double_jump == true:
			velocity.y = -double_jump_height
			is_double_jumping = true
			can_double_jump = false
			
	if not Input.is_action_pressed("jump"):
		if velocity.y < 0:
			velocity.y += gravity * delta * lower_jump

func set_sprite_flip() -> void:
	if horizontal_move_direciton.x == -1:
		sprite_area_2d.scale.x = -1
	elif horizontal_move_direciton.x == 1:
		sprite_area_2d.scale.x = 1

func set_animation() -> void:
	set_sprite_flip()
	
	if not is_on_floor():
		if is_double_jumping == true:
			animation_player.play("double_jump")
			await animation_player.animation_finished
			is_double_jumping = false
		else:
			if velocity.y < 0:
				animation_player.play("jump")
			if velocity.y > 0:
				animation_player.play("fall")
		
	elif horizontal_move_direciton.x:
		animation_player.play("move")
	else:
		animation_player.play("idle")


func _on_horizontal_attack_1_area_2d_area_entered(area: Area2D) -> void:
	global_position.x -= sprite_area_2d.scale.x * 5

func _on_horizontal_attack_2_area_2d_area_entered(area: Area2D) -> void:
	global_position.x -= sprite_area_2d.scale.x * 5

func _on_up_attack_area_2d_area_entered(area: Area2D) -> void:
	pass

func _on_down_attack_area_2d_4_area_entered(area: Area2D) -> void:
	can_double_jump = true
	can_dash = true
	velocity.y = -attack_jump_height

func _on_player_hurt_area_2d_area_entered(area: Area2D) -> void:
	player_shining = true
	currcent_state = State.HURT_STATE

func _on_invincible_timer_timeout() -> void:
	player_hurt_collision.disabled = false
	player_shining = false
	
