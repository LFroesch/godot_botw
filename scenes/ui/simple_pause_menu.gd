# simple_pause_menu.gd
extends CanvasLayer

# Keep this script simple - just handle pause/resume

@onready var pause_menu = $PauseMenu
@onready var settings_menu = $SettingsMenu

func _ready():
	# Hide menu at start
	pause_menu.visible = false
	settings_menu.visible = false

func _input(event):
	if event.is_action_pressed("menu"):  # This is the Escape key by default
		toggle_pause_menu()

func toggle_pause_menu():
	# Toggle menu visibility
	pause_menu.visible = !pause_menu.visible
	
	# Toggle game pause state
	get_tree().paused = pause_menu.visible
	
	# Toggle mouse mode
	if pause_menu.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
	
func _on_resume_button_pressed() -> void:
	toggle_pause_menu()

func _on_settings_button_pressed() -> void:
	settings_menu.visible = true

func _on_back_button_pressed() -> void:
	settings_menu.visible = false

func _on_unstuck_button_pressed() -> void:
	get_tree().paused = false

	var level = get_tree().current_scene
	
	print("Unstuck button pressed")
	print("Parent node: ", get_parent())
	print("Current scene: ", level)
	print("Level has switch_level method: ", level.has_method("switch_level"))
	
	if level and level.has_method("switch_level"):
		print("Attempting to switch level")
		level.switch_level('overworld', Vector3(-0.158185, 12.54015, -86.60701))
	else:
		print("Could not find level to switch")
