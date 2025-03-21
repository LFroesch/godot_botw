extends Enemy

const simple_attacks = {
	'slice1': "1H_Melee_Attack_Slice_Diagonal",
	'slice2': "1H_Melee_Attack_Slice_Horizontal"
}

func _ready() -> void:
	attack_radius = 1.5
	health = 3

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.5, 3.5)
	if position.distance_to(player.position) < attack_radius:
		melee_attack_animation()

func melee_attack_animation() -> void:
	attack_animation.animation = simple_attacks['slice1' if rng.randi() % 2 else 'slice2']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func can_damage(value: bool) -> void:
	$skin/Rig/Skeleton3D/BoneAttachment3D/Bone.can_damage = value
