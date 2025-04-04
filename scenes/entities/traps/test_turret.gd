class_name TestTurret
extends Node3D

signal cast_spell(type, position, direction, size)

@export var fireball_size: float = 1.0  # Size of the fireball

@onready var raycast: RayCast3D = $Raycast3D


func shoot_fireball() -> void:
	# Debug print
	print("Shoot fireball called")
	
	# Use the raycast's forward direction
	var direction = Vector2(raycast.global_transform.basis.x.x, raycast.global_transform.basis.x.z)
	
	# Get the global position of the turret
	var spawn_position = global_position
	
	# Debug prints
	print("Spawn position: ", spawn_position)
	print("Direction: ", direction)
	
	# Emit the cast_spell signal to create the fireball
	emit_signal("cast_spell", "fireball", spawn_position, direction, fireball_size)


func _on_shoot_timer_timeout() -> void:
	shoot_fireball()
