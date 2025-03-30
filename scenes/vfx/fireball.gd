extends Area3D

var direction: Vector2
var speed = 5.0
var base_hover_height = 0.8
var hover_height = 0.8

@onready var ray_cast = $RayCast3D

func _ready() -> void:
	scale = Vector3(0.1, 0.1, 0.1)
	
	get_tree().create_timer(5.0).timeout.connect(_on_timer_timeout)

func _process(delta: float) -> void:
	var horizontal_movement = Vector3(direction.x, 0, direction.y) * speed * delta
	
	position.x += horizontal_movement.x
	position.z += horizontal_movement.z
	
	if ray_cast.is_colliding():
		var collision_point = ray_cast.get_collision_point()
		var target_y = collision_point.y + hover_height
		position.y = lerp(position.y, target_y, 0.2)

func _on_body_entered(body: Node3D) -> void:
	if "hit" in body:
		body.hit()
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()

func setup(size: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3.ONE * size, 0.5)
	hover_height = base_hover_height * size
