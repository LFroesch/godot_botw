# camera_controller.gd
extends Node3D

@export var horizontal_acceleration := 2.0
@export var vertical_acceleration := 1.0
@export var min_limit_x: float = -0.8
@export var max_limit_x: float = -0.2
@export var mouse_acceleration := 0.005

# New mouse settings
@export var mouse_sensitivity := 0.3
@export var mouse_smoothing := 0.3

# For mouse smoothing
var target_rotation = Vector2.ZERO
var current_rotation_velocity = Vector2.ZERO
var last_controller_input_time := 0.0

func _ready() -> void:
	# Initialize target rotation with current rotation
	target_rotation.x = rotation.x
	target_rotation.y = rotation.y
	
	# Lock mouse to game window for better control during gameplay
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Handle controller input
	var joy_dir = Input.get_vector("pan_left", "pan_right", "pan_up", "pan_down")
	
	if joy_dir.length() > 0:
		# When controller is used, directly apply rotation like before
		rotate_from_vector(joy_dir * delta * Vector2(horizontal_acceleration, vertical_acceleration))
		last_controller_input_time = Time.get_ticks_msec() / 1000.0
		
		# Update target rotation to match actual rotation
		target_rotation.x = rotation.x
		target_rotation.y = rotation.y
	else:
		# Only apply mouse smoothing if we haven't used the controller recently
		var time_since_controller = Time.get_ticks_msec() / 1000.0 - last_controller_input_time
		if time_since_controller > 0.2:
			apply_smoothed_rotation(delta)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		# Store rotation as target for smoothing
		target_rotation.x -= event.relative.y * mouse_sensitivity * 0.01
		target_rotation.y -= event.relative.x * mouse_sensitivity * 0.01
		
		# Clamp vertical target rotation
		target_rotation.x = clamp(target_rotation.x, min_limit_x, max_limit_x)
	
	# Toggle mouse capture with ESC key
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Apply smoothed rotation for mouse input
func apply_smoothed_rotation(delta: float):
	# Calculate target rotation difference
	var rotation_diff = Vector2(
		target_rotation.x - rotation.x,
		target_rotation.y - rotation.y
	)
	
	# Apply smoothing using spring physics
	current_rotation_velocity = current_rotation_velocity.lerp(rotation_diff * 10, mouse_smoothing)
	
	# Apply velocity with delta time
	rotation.x += current_rotation_velocity.x * delta
	rotation.y += current_rotation_velocity.y * delta
	
	# Make sure vertical rotation stays within limits
	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)

# Original rotate function for controller input
func rotate_from_vector(v: Vector2):
	if v.length() == 0: return
	rotation.y -= v.x
	rotation.x -= v.y
	rotation.x = clamp(rotation.x, min_limit_x, max_limit_x)
