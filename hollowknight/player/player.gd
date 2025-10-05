extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Sprite2D

var gravity = 300
var horizontal_move_speed = 150
var horizontal_move_direciton : Vector2 = Vector2.ZERO
var deceleraion_speed = 30

var jump_height = 200
var lower_jump = 4
var jump_state

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	horizontal_move()
	jump_logic(delta)
	set_animation()
	move_and_slide()
	
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
	if velocity.y < 0 and not Input.is_action_pressed("jump"):
		velocity.y += gravity * delta * lower_jump
		jump_state = 0

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
