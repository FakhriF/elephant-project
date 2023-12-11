extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	if _check_progress():
		$ContinueButton.disabled = false


func _on_exit_button_pressed():
	get_tree().change_scene_to_file("res://menu/scenes/quit_confirm.tscn")



func _on_start_game_button_pressed():
	get_tree().change_scene_to_file("res://menu/scenes/select_map_scene.tscn")
	


func _on_continue_button_pressed():
	
	get_tree().change_scene_to_file("res://gameStage/MainStage.tscn")

func _check_progress() -> bool:
	var saveName
	match Profile.gameProgress:
		"Profile 1":
			saveName = "res://savegame1.bin"
		"Profile 2":
			saveName = "res://savegame2.bin"       
		"Profile 3":
			saveName = "res://savegame3.bin"

	var file = FileAccess.open(saveName, FileAccess.READ)

	if file:
		var fileContents = file.get_as_text()
		file.close()

		if fileContents:
			var saveData = JSON.parse_string(fileContents)

			for key in saveData.keys():
				if key != "username":
					print("Additional key found:", key)
					return true  # Additional key found
		else:
			print("Empty file.")
	else:
		print("Error reading file.")
	
	return false  # No additional keys found

