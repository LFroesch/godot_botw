class_name Enemy
extends CharacterBody3D

@onready var move_state_machine = $AnimationTree.get("parameters/MoveStateMachine/playback")
@onready var attack_animation = $AnimationTree.get_tree_root().get_node("AttackAnimation")
@onready var player = get_tree().get_first_node_in_group("Player")
@onready var skin = get_node("skin")

@export var walk_speed := 2.0
@export var speed = walk_speed
var speed_modifier := 1.0
@export var notice_radius := 30.0
@export var attack_radius := 3.0
var health = 5:
	set(value):
		health = value
		if health <= 0:
			queue_free()
@warning_ignore("unused_signal")
signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)

var rng = RandomNumberGenerator.new()
var squash_and_stretch := 1.0:
	set(value):
		squash_and_stretch = value
		var negative = 1.0 + (1.0 - squash_and_stretch)
		skin.scale = Vector3(negative, squash_and_stretch, negative)

# Add this property to your Enemy base class
@export var gravity_force := 9.8

func move_to_player(delta):
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y -= gravity_force * delta
	
	# if you enter range
	if position.distance_to(player.position) < notice_radius:
		var target_dir = (player.position - position).normalized()
		var target_vec2 = Vector2(target_dir.x, target_dir.z)
		var target_angle = -target_vec2.angle() + PI/2
		rotation.y = rotate_toward(rotation.y, target_angle, delta * 1.0)
		if position.distance_to(player.position) > attack_radius:
			# Keep only the x and z components
			velocity.x = target_vec2.x * speed * speed_modifier
			velocity.z = target_vec2.y * speed * speed_modifier
			move_state_machine.travel("walk")
		else:
			velocity.x = 0
			velocity.z = 0
			move_state_machine.travel("idle")
		move_and_slide()
	# if you leave the range
	else:
		velocity.x = 0
		velocity.z = 0
		move_state_machine.travel("idle")
		move_and_slide()

func stop_movement(start_duration: float, end_duration: float):
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit() -> void:
	if not $Timers/InvulTimer.time_left:
		do_squash_and_stretch(1.2, 0.15)
		$Timers/InvulTimer.start()
		health -= 1

func do_squash_and_stretch(value: float, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(self, "squash_and_stretch", value, duration)
	tween.tween_property(self, "squash_and_stretch", 1.0, duration * 1.8)
