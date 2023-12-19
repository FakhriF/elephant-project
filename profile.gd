extends Node


var profileList = []

var character_select = []

var stage_select = ""

var gameProgress

var hasSave = false

var difficulty = "Normal"

func _check_progress() -> bool:
	var saveName
	match Profile.gameProgress:
		"Profile 1":
			saveName = "res://savegame1.bin"
		"Profile 2":
			saveName = "res://savegame2.bin"       
		"Profile 3":
			saveName = "res://savegame3.bin"
		_:
			print("Invalid profile.")
			return false

	var file = FileAccess.open(saveName, FileAccess.READ)

	if file:
		var fileContents = file.get_as_text()
		file.close()

		if fileContents:
			var saveData = JSON.parse_string(fileContents)

			for key in saveData.keys():
				if key != "username":
					print("Additional key found:", key)
					return true 
		else:
			print("Empty file.")
	else:
		print("Error reading file.")
	
	return false 
