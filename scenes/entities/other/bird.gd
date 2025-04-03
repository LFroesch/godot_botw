extends PathFollow3D

@export var speed := 30

func _process(delta: float) -> void:
	progress += speed * delta
