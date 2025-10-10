extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var black_dash_is_ready : bool = false

func _ready() -> void:
	black_dash_is_ready = true
	
func play_gather_animation() -> void:
	animation_player.play("gather")
