extends Node2D

@onready var createProfileNodes = $CreateProfile
@onready var SelectProfileNodes = $SelectProfile
@onready var ProfileButton = $Welcome/SelectProfileButton
@onready var welcomeNodes = $Welcome
@onready var usernameText = $CreateProfile/ProfileTextfield

# Called when the node enters the scene tree for the first time.
func _ready():
	createProfileNodes.visible = false
	SelectProfileNodes.visible = false
	if FileAccess.file_exists("res://savegame.bin") == true:
		ProfileButton.disabled = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_create_profile_button_pressed():
	createProfileNodes.visible = true

func _on_select_profile_button_pressed():
	if FileAccess.file_exists("res://savegame.bin") == true:
		SelectProfileNodes.visible = true
		var file  = FileAccess.open("res://savegame.bin", FileAccess.READ)
		var current_line = JSON.parse_string(file.get_line())
		file.close()
		GameSystem.profile = current_line["username"]
		$SelectProfile/Profile1.text = GameSystem.profile
		print(GameSystem.profile)
		
		
	
func _on_create_profile_ok_button_pressed():
	print(usernameText.get_text()) #Username Value
	if (usernameText.get_text() != ""):
		var file  = FileAccess.open("res://savegame.bin", FileAccess.WRITE)
		var profile_data: Dictionary = {
			"username": usernameText.get_text()
			}
		var jstr = JSON.stringify(profile_data)
		file.store_line(jstr)
		
		get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
	else:
		print("Username Masih Kosong!")
	


func _on_background_button_pressed():
	createProfileNodes.visible = false
	print("Tap!")


func _on_profile_1_pressed():
	get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
