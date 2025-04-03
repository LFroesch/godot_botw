# dungeon.gd
extends Level
func _on_door_area_body_entered(_body: Node3D) -> void:
	# Exit dungeon to overworld at specific position
	switch_level('overworld', Vector3(-107.139, -39.00866, 328.0593))


func _on_area_3d_body_entered(body: Node3D) -> void:
	print('entered')
	switch_level('dungeon', Vector3(-68.12434, 1.050913, 0.010175))
