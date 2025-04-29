# overworld.gd
extends Level

func _ready() -> void:
	level_id = "overworld"
	super._ready()

func _on_castlearea_body_entered(_body: Node3D) -> void:
	# Enter dungeon at specific position
	switch_level('dungeon', Vector3(-68.12434, 1.050913, 0.010175)
)
