extends CharacterBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var material_timer: Timer = $MaterialTimer

func _physics_process(delta: float) -> void:
	pass


func _on_boss_hurt_area_2d_area_entered(area: Area2D) -> void:
	material_timer.start()
	sprite_2d.use_parent_material = false

func _on_material_timer_timeout() -> void:
	sprite_2d.use_parent_material = true
