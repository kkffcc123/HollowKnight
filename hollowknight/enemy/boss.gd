extends CharacterBody2D


func _physics_process(delta: float) -> void:
	pass


func _on_boss_hurt_area_2d_area_entered(area: Area2D) -> void:
	print("boss injured!")
