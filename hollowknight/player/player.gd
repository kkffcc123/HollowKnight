extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

enum State{
	NORMAL,
	DASH,
}

var currcent_state = State.NORMAL

var can_dash : bool = false
var is_dashing : bool = false
var dash_gravity = 0
#var dash_cd = 4.0
var dash_speed = 100
var dash_direciton : Vector2 = Vector2.ZERO

var gravity = 300
var horizontal_move_speed = 150
var horizontal_move_direciton : Vector2 = Vector2.ZERO
var deceleraion_speed = 30

var jump_height = 200
var lower_jump = 4
var jump_state

var can_double_jump : bool = false
var double_jump_height = 100
var is_double_jumping : bool = false

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

	move_and_slide()
	
func normal_physics_process(delta: float) -> void:
	double_jump_refresh()
	dash_refresh()
	horizontal_move()
	jump_logic(delta)
	set_animation()
	change_state_to_dash()

func dash_physics_process(delta: float) -> void:
	can_dash = false
	
	dash_direciton.x = horizontal_move_direciton.x
	if dash_direciton.x == 0:
		dash_direciton.x = -1 if sprite_2d.flip_h == true else 1
	
	velocity.x = dash_direciton.x * dash_speed
	animation_player.play("dash")
	await animation_player.animation_finished
	is_dashing = false
	currcent_state = State.NORMAL

func change_state_to_dash() -> void:
	if Input.is_action_just_pressed("dash") and can_dash == true:
		is_dashing = true
		currcent_state = State.DASH

func dash_refresh() -> void:
	if is_on_floor():
		can_dash = true

func double_jump_refresh() -> void:
	if is_on_floor():
		can_double_jump = true

func horizontal_move() -> void:
	horizontal_move_direciton.x = Input.get_axis("move_left","move_right")
	if horizontal_move_direciton.x:
		velocity.x = horizontal_move_direciton.x * horizontal_move_speed
	else: 
		velocity.x = move_toward(velocity.x,0,deceleraion_speed)
	
func jump_logic(delta : float) -> void:
	if Input.is_action_just_pressed("jump"):
		jump_state = -1
		
	if is_on_floor() and jump_state == -1:
		velocity.y = jump_state * jump_height
	if not Input.is_action_pressed("jump"):
		jump_state = 0
		if velocity.y < 0:
			velocity.y += gravity * delta * lower_jump

func set_sprite_flip() -> void:
	if horizontal_move_direciton.x == -1:
		sprite_2d.flip_h = true
	elif horizontal_move_direciton.x == 1:
		sprite_2d.flip_h = false

func set_animation() -> void:
	set_sprite_flip()
	
	if not is_on_floor():
		if velocity.y < 0:
			animation_player.play("jump")
		if velocity.y > 0:
			animation_player.play("fall")
		
	elif horizontal_move_direciton.x:
		animation_player.play("move")
	else:
		animation_player.play("idle")
