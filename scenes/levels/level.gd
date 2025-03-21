extends Node3D

var fireball_scene: PackedScene	= preload("res://scenes/vfx/fireball.tscn")

func _ready() -> void:
	for entity in $Entities.get_children():
		if entity.has_signal("cast_spell"):
			entity.connect("cast_spell", create_fireball)

func create_fireball(_type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	var fireball = fireball_scene.instantiate()
	$Projectiles.add_child(fireball)
	fireball.global_position = pos
	fireball.direction = direction
	fireball.setup(size)
