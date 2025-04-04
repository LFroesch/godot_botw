# player.gd
extends CharacterBody3D

@export var jump_height : float = 4.0
@export var jump_time_to_peak : float = 0.4
@export var jump_time_to_descent : float = 0.3

@onready var jump_velocity : float = ((2.0 * jump_height) / jump_time_to_peak) * -1.0
@onready var jump_gravity : float = (-2.0 * jump_height) / (jump_time_to_peak * jump_time_to_peak) * -1.0
@onready var fall_gravity : float = (-2.0 * jump_height) / (jump_time_to_descent * jump_time_to_descent) * -1.0

@export var base_speed := 4.5
@export var run_speed := 8.0
@export var defend_speed := 2.0
var speed_modifier := 1.0

@onready var camera = $CameraController/Camera3D
@onready var skin = $GodetteSkin
@onready var ui = $UI
@onready var run_particles: GPUParticles3D = $RunParticles

# New combat variables
var combat_mode := false
var combat_orientation_speed := 10.0

var movement_input := Vector2.ZERO
var defend := false:
	set(value):
		if not defend and value:
			skin.defend(true)
		if defend and not value:
			skin.defend(false)
		defend = value
var weapon_active := true:
	set(value):
		weapon_active = value
		if weapon_active:
			ui.get_node("Spells").hide()
		else:
			ui.get_node("Spells").show()
			
var health = 5:
	set(value):
		ui.update_health(value, value - health)
		health = value
		if health <= 0:
			# Disable player controls
			set_physics_process(false)
			skin.death_animation()
			# Wait for animation to finish
			var level = get_parent().get_parent() # Assuming player -> Entities -> Level
			if level.has_method("switch_level"):
				level.switch_level('overworld', Vector3(-0.158185, 12.54015, -86.60701))
var energy = 100:
	set(value):
		energy = min(100, value)
		ui.update_energy(energy)
var stamina = 100:
	set(value):
		ui.update_stamina(stamina, value)
		if stamina == 100 and value < 100:
			ui.change_stamina_alpha(1.0)
		if value == 100:
			ui.change_stamina_alpha(0.0)
		stamina = clamp(value, 0, 100)

signal cast_spell(type: String, pos: Vector3, direction: Vector2, size: float)
enum spells {FIREBALL, HEAL}
var current_spell = spells.FIREBALL

func _ready() -> void:
	energy = 100
	weapon_active = true
	skin.switch_weapon(weapon_active)
	ui.setup(health)

func _physics_process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("player_position", global_position)
	move_logic(delta)
	jump_logic(delta)
	ability_logic()
	update_combat_orientation(delta)  # Add this line
	
	if Input.is_action_just_pressed("ui_accept"):
		hit()
	move_and_slide()
	physics_logic()
	

func move_logic(delta) -> void:
	movement_input = Input.get_vector("left", "right", "forward", "backward").rotated(-camera.global_rotation.y)
	var is_running: bool = Input.is_action_pressed("run")
	
	if movement_input != Vector2.ZERO:
		# Run Speed 
		var speed = run_speed if is_running else base_speed
		speed = defend_speed if defend else speed
		var vel_2d = Vector2(velocity.x, velocity.z)
		var target_vel = Vector2(movement_input.x * speed, movement_input.y * speed) * speed_modifier
		vel_2d = vel_2d.lerp(target_vel, 0.8) # Adjust between .3-1.0 for snappier adjusting
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		# Update Animation
		skin.set_move_state('Running')
		# Update Facing Direction
		var target_angle = -movement_input.angle() + PI/2
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, 6.0 * delta)
		print(position)
	else:
		# Logic for Idle / Return to Idle
		var vel_2d = Vector2(velocity.x, velocity.z)
		vel_2d = vel_2d.move_toward(Vector2.ZERO, base_speed * 5.0 * delta)
		velocity.x = vel_2d.x
		velocity.z = vel_2d.y
		# Update Animation
		skin.set_move_state('Idle')
	
	run_particles.emitting = is_on_floor() and is_running and movement_input != Vector2.ZERO
	
	# Steps Sound Logic (Disabled because I don't like the sound)
	#if is_on_floor() and movement_input:
	#	if not $Sounds/StepsSound.playing:
	#		$Sounds/StepsSound.playing = true
	#else:
	#	$Sounds/StepsSound.playing = false

func jump_logic(delta) -> void:
	# Check if on floor and jump button pressed
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and stamina >= 20:
			velocity.y = -jump_velocity
			do_squash_and_stretch(1.2, 0.15)
			#stamina -= 20
	else:
		skin.set_move_state('Jump')
	# Constantly enforce gravity
	var gravity = jump_gravity if velocity.y > 0.0 else fall_gravity
	velocity.y -= gravity * delta

func ability_logic() -> void:
	# actual attack
	if Input.is_action_just_pressed("ability"):
		if weapon_active:
			skin.attack()
		else:
			if energy >= 20:
				skin.cast_spell()
				stop_movement(0.3, 0.8)
		
	# defend
	defend = Input.is_action_pressed("block")
	
	# switch weapon
	if Input.is_action_just_pressed("switch weapon") and not skin.attacking:
		weapon_active = not weapon_active
		skin.switch_weapon(weapon_active)
		do_squash_and_stretch(1.05, 0.1)
	
	if Input.is_action_just_pressed("switch spell") and not skin.attacking:
		current_spell = spells[spells.keys()[(int(current_spell) + 1) % len(spells)]]
		ui.update_spell(spells, current_spell)

# New function for combat orientation
func update_combat_orientation(delta):
	# Check if in combat mode (attacking or defending)
	combat_mode = skin.attacking or defend
	
	if combat_mode:
		# Get camera's forward direction (ignoring vertical component)
		var camera_dir = -camera.global_transform.basis.z
		camera_dir.y = 0  # Zero out vertical component
		camera_dir = camera_dir.normalized()
		
		# Calculate the target angle based on camera direction
		var target_angle = atan2(camera_dir.x, camera_dir.z)
		
		# Smoothly rotate the character to face camera direction
		skin.rotation.y = rotate_toward(skin.rotation.y, target_angle, combat_orientation_speed * delta)

func stop_movement(start_duration: float, end_duration: float):
	var tween = create_tween()
	tween.tween_property(self, "speed_modifier", 0.0, start_duration)
	tween.tween_property(self, "speed_modifier", 1.0, end_duration)

func hit():
	if not $Timers/InvulnTimer.time_left:
		skin.hit()
		stop_movement(0.3, 0.3)
		health -= 1
		$Timers/InvulnTimer.start()

func do_squash_and_stretch(value: float, duration: float = 0.1):
	var tween = create_tween()
	tween.tween_property(skin, "squash_and_stretch", value, duration)
	tween.tween_property(skin, "squash_and_stretch", 1.0, duration * 1.8)

func shoot_magic(pos: Vector3) -> void:
	var forward_direction = Vector2(sin(skin.rotation.y), cos(skin.rotation.y))
	if current_spell == spells.FIREBALL:
		energy -= 20
		cast_spell.emit("Fireball", pos, forward_direction, 1.0)
		# Left fireball (rotated -15 degrees)
		var left_angle = skin.rotation.y - deg_to_rad(10)
		var left_direction = Vector2(sin(left_angle), cos(left_angle))
		cast_spell.emit("Fireball", pos, left_direction, 1.0)
		
		# Right fireball (rotated +15 degrees)
		var right_angle = skin.rotation.y + deg_to_rad(10)
		var right_direction = Vector2(sin(right_angle), cos(right_angle))
		cast_spell.emit("Fireball", pos, right_direction, 1.0)
	if current_spell == spells.HEAL:
		health += 1
		energy -= 20

func _on_energy_recovery_timer_timeout() -> void:
	energy += 1

func _on_stamina_recovery_timer_timeout() -> void:
	stamina += 1

#func _input(event: InputEvent) -> void:
#	if event.is_action_pressed("exit_game"):
#		get_tree().quit()

func physics_logic() -> void:
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider is RigidBody3D:
			var damping = 0.7
			collider.apply_central_impulse(-get_slide_collision(i).get_normal() * damping)
