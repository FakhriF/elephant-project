extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_yes_button_pressed():
	get_tree().quit()


func _on_no_button_pressed():
	get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
