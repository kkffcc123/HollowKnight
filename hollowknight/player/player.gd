extends CharacterBody2D

var gravity = 300
var horizontal_move_speed = 150
var horizontal_move_direciton : Vector2 = Vector2.ZERO
var deceleraion_speed = 30
var jump_height = 200
var lower_jump = 4

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	horizontal_move()
	jump_logic(delta)
	move_and_slide()
	
func horizontal_move() -> void:
	horizontal_move_direciton.x = Input.get_axis("move_left","move_right")
	if horizontal_move_direciton.x:
		velocity.x = horizontal_move_direciton.x * horizontal_move_speed
	else: 
		velocity.x = move_toward(velocity.x,0,deceleraion_speed)
	
func jump_logic(delta : float) -> void:
	var jump_state
	if Input.is_action_just_pressed("jump"):
		jump_state = -1
	
	if is_on_floor() and jump_state == -1:
		velocity.y = jump_state * jump_height
	if velocity.y < 0 and not Input.is_action_pressed("jump"):
		velocity.y += gravity * delta * lower_jump
