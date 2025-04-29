# colloseum.gd
extends Level

func _ready() -> void:
	level_id = "colloseum"
	super._ready()

func _on_door_area_body_entered(_body: Node3D) -> void:
	pass

func _on_area_3d_body_entered(body: Node3D) -> void:
	print('entered')
	switch_level('colloseum', Vector3(-2, 0, -50))
