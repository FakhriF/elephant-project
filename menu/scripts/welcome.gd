extends Node2D

@onready var createProfileNodes = $CreateProfile
@onready var SelectProfileNodes = $SelectProfile
@onready var ProfileButton = $Welcome/SelectProfileButton
@onready var welcomeNodes = $Welcome
@onready var usernameText = $CreateProfile/ProfileTextfield
@onready var errorText = $CreateProfile/ErrorText

var timer 

# Called when the node enters the scene tree for the first time.
func _ready():
	errorText.visible = false
	createProfileNodes.visible = false
	SelectProfileNodes.visible = false
	if (FileAccess.file_exists("res://savegame1.bin") == true) or (FileAccess.file_exists("res://savegame2.bin") == true) or (FileAccess.file_exists("res://savegame3.bin") == true) :
		ProfileButton.disabled = false

func saveGame(Username: Control):
	var i = 0

	while i < 3:
		var saveName = "res://savegame" + str(i + 1) + ".bin"
		
		# Check if the file already exists.
		if FileAccess.file_exists(saveName):
			i = i + 1
			continue
		var file = FileAccess.open(saveName, FileAccess.WRITE)
		var profile_data: Dictionary = {
			"username": Username.get_text()
		}
		var jstr = JSON.stringify(profile_data)
		file.store_line(jstr)
		Profile.profileList.append(Username.get_text())
		Profile.gameProgress = "Profile " + str(i + 1)
		i += 1  # Increment i
		return true
		break

	# Check for the maximum number of profiles.
	if i == 3:
		return false

func loadGame():
	for i in range(3):
		var saveName = "res://savegame" + str(i + 1) + ".bin"
		if FileAccess.file_exists(saveName) == true:
			SelectProfileNodes.visible = true
			var file  = FileAccess.open(saveName, FileAccess.READ)
			var current_line = JSON.parse_string(file.get_line())
			file.close()
			Profile.profileList = current_line["username"]
			if saveName == "res://savegame1.bin":
				$SelectProfile/Profile1.text = "PROFILE 1: " + Profile.profileList
			if saveName == "res://savegame2.bin":
				$SelectProfile/Profile2.text = "PROFILE 2: " + Profile.profileList
			if saveName == "res://savegame3.bin":
				$SelectProfile/Profile3.text = "PROFILE 3: " + Profile.profileList
		else:
			pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if (createProfileNodes.visible && Input.is_action_pressed("Enter_KEY")):
		_on_create_profile_ok_button_pressed()
	if (errorText.visible == true):
		if timer >= 0:
			print(timer)
			timer -= delta
		else:	
			errorText.visible = false

func _on_create_profile_button_pressed():
	createProfileNodes.visible = true

func _on_select_profile_button_pressed():
	loadGame()

	
func _on_create_profile_ok_button_pressed():
	print(usernameText.get_text()) #Username Value
	if (usernameText.get_text() != "" && usernameText.get_text() != " "):
		var usernameValidity = usernameText.get_text().split()
		var bannedLetter = "&=_'-+,><?/:;[]{}|!@#$%^&*()`~"
		var usernameSafety = true
		for letter in usernameValidity:
			if letter in bannedLetter.split():
				usernameErrorStatusCode(1)
				usernameSafety = false
				break
		if usernameSafety:
			if saveGame(usernameText):
				get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
			else:
				usernameErrorStatusCode(2)
	else:
		usernameErrorStatusCode(0)
	
func usernameErrorStatusCode(code):
	timer = 3
	if code == 0:
		print("Username masih kosong!")
		errorText.text = "Username still empty!"
	elif code == 1:
		print("Terdapat karakter invalid! Gunakan huruf alfabet dan angka")
		errorText.text = "Invalid characters"
	elif code == 2:
		print("Maximum Number of Profiles")
		errorText.text = "Maximum Number of Profiles"
	errorText.visible = true
	
func _on_background_button_pressed():
	createProfileNodes.visible = false
	SelectProfileNodes.visible = false
	print("Tap!")


func _on_profile_1_pressed():
	if FileAccess.file_exists("res://savegame1.bin"):
		Profile.gameProgress = "Profile 1"
		get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")


func _on_profile_2_pressed():
	if FileAccess.file_exists("res://savegame2.bin"):
		Profile.gameProgress = "Profile 1"
		get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
		


func _on_profile_3_pressed():
	if FileAccess.file_exists("res://savegame3.bin"):
		Profile.gameProgress = "Profile 1"
		get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")
