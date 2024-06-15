extends Control

@export var game_scene: PackedScene
@onready var new_game_button = $"MarginContainer/VBoxContainer2/MarginContainer2/New Game Button"

func _ready():
	new_game_button.grab_focus()
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	pass

func _on_new_game_button_pressed():
	get_tree().change_scene_to_packed(game_scene)

func _on_options_button_pressed():
	pass # Replace with function body.


func _on_quit_button_pressed():
	get_tree().quit()
	pass # Replace with function body.
