extends Node2D

@onready var createProfileNodes = $CreateProfile
@onready var welcomeNodes = $Welcome
@onready var usernameText = $CreateProfile/ProfileTextfield

# Called when the node enters the scene tree for the first time.
func _ready():
	createProfileNodes.visible = false
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_create_profile_button_pressed():
	createProfileNodes.visible = true
	
	
func _on_create_profile_ok_button_pressed():
	print(usernameText.get_text()) #Username Value
	if (usernameText.get_text() != ""):
		get_tree().change_scene_to_file("res://scenes/main_menu_scene.tscn")
	else:
		print("Username Masih Kosong!")
	


func _on_background_button_pressed():
	createProfileNodes.visible = false
	print("Tap!")
	
