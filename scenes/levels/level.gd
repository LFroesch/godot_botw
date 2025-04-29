#level.gd
class_name Level
extends Node3D
var level_id = "unknown"

var pause_menu_scene: PackedScene = preload("res://scenes/ui/simple_pause_menu.tscn")

var fade_rect: ColorRect
var fireball_scene: PackedScene	= preload("res://scenes/vfx/fireball.tscn")
const scenes = {
	'dungeon': "res://scenes/levels/dungeon.tscn",
	'overworld': "res://scenes/levels/overworld.tscn",
	'colloseum': "res://scenes/levels/colloseum.tscn"
}
# Static variable to store where we're going
static var next_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	var pause_menu = pause_menu_scene.instantiate()
	add_child(pause_menu)
	
	var canvas_layer = CanvasLayer.new()
	add_child(canvas_layer)
	fade_rect = ColorRect.new()
	fade_rect.color = Color(0, 0, 0, 0) # Start transparent
	fade_rect.anchor_right = 1.0
	fade_rect.anchor_bottom = 1.0
	fade_rect.grow_horizontal = Control.GROW_DIRECTION_BOTH
	fade_rect.grow_vertical = Control.GROW_DIRECTION_BOTH
	canvas_layer.add_child(fade_rect)
	
	for entity in $Entities.get_children():
		if entity.has_signal("cast_spell"):
			entity.connect("cast_spell", create_fireball)
	
	var player = $Entities/Player
	print("Found player: ", player != null)  # Debug check

	if player and next_position != Vector3.ZERO:
		print("Moving player from: ", player.global_position, " to: ", next_position)
		player.global_position = next_position
		next_position = Vector3.ZERO
		print("New position: ", player.global_position)  # Verify it changed
		# Fade in from black
		fade_in()

func create_fireball(_type: String, pos: Vector3, direction: Vector2, size: float) -> void:
	var fireball = fireball_scene.instantiate()
	$Projectiles.add_child(fireball)
	fireball.global_position = pos
	fireball.direction = direction
	fireball.setup(size)
	
func switch_level(target: String, pos: Vector3):
	# Store where the player should appear
	next_position = pos
	
	# Fade out to black
	fade_out()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file(scenes[target])

func fade_out():
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 1), 0.5)

func fade_in():
	fade_rect.color = Color(0, 0, 0, 1)  # Start black
	var tween = create_tween()
	tween.tween_property(fade_rect, "color", Color(0, 0, 0, 0), 0.5)
