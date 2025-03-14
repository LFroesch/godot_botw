extends Enemy

const simple_attacks = {
	'slice': "1H_Melee_Attack_Slice_Diagonal",
	'stab': "1H_Melee_Attack_Stab"
}

func _physics_process(delta: float) -> void:
	move_to_player(delta)

func _on_attack_timer_timeout() -> void:
	$Timers/AttackTimer.wait_time = rng.randf_range(2.5, 3.5)
	if position.distance_to(player.position) < attack_radius:
		melee_attack_animation()

func melee_attack_animation() -> void:
	attack_animation.animation = simple_attacks['slice' if rng.randi() % 2 else 'stab']
	$AnimationTree.set("parameters/AttackOneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
