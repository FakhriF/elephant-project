extends Node2D

@onready var next_stage = preload("res://gameStage/MainStage.tscn")
@onready var game_instance = next_stage.instantiate()
@onready var aurel_unit: Unit = game_instance.get_node("GameBoard/Aurel")
@onready var theon_unit: Unit = game_instance.get_node("GameBoard/Theon")
@onready var thea_unit: Unit = game_instance.get_node("GameBoard/Thea")
# Called when the node enters the scene tree for the first time.

func _ready():
	$"Start Button".disabled = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Profile.character_select.size() == 3:
		$"Start Button".disabled = false
	else:
		$"Start Button".disabled = true
	


func _on_start_button_pressed():
	if Profile.character_select.size() < 3:
		print("Please select another character")
	else:
		Profile.hasSave = false
		get_tree().change_scene_to_file("res://gameStage/MainStage.tscn")
		

func _display_splash_art(unit_name: String):
	if unit_name == "Aurel":
		$"Button Character 1/Aurel-splashArt".visible = true
		$"Button Character 3/Thea-splashArt".visible = false
		$"Button Character 4/Theon-splashArt".visible = false
	elif unit_name == "Thea":
		$"Button Character 1/Aurel-splashArt".visible = false
		$"Button Character 3/Thea-splashArt".visible = true
		$"Button Character 4/Theon-splashArt".visible = false
	elif unit_name == "Theon":
		$"Button Character 1/Aurel-splashArt".visible = false
		$"Button Character 3/Thea-splashArt".visible = false
		$"Button Character 4/Theon-splashArt".visible = true
	
	
func _on_button_character_1_toggled(button_pressed):
	if(button_pressed):
		if Profile.character_select.size() < 3:
			$HP/isi.text = str(aurel_unit.hp)
			$EP/isi.text = str(aurel_unit.energy)
			_display_splash_art("Aurel")
			$"Button Character 1/CharacterColorBlock1".visible = true
			Profile.character_select.append("Aurel")
			print(Profile.character_select)
		else: 
			print("Maximum Number of Character Selected!")
	else:
		Profile.character_select.erase("Aurel")
		$HP/isi.text = str(aurel_unit.hp)
		$EP/isi.text = str(aurel_unit.energy)
		print(Profile.character_select)
		$"Button Character 1/CharacterColorBlock1".visible = false


func _on_button_character_3_toggled(button_pressed):
	if(button_pressed):
		$HP/isi.text = str(thea_unit.hp)
		$EP/isi.text = str(thea_unit.energy)
		Profile.character_select.append("Thea")
		_display_splash_art("Thea")
		$"Button Character 3/CharacterColorBlock3".visible = true
		print(Profile.character_select)
	else:
		Profile.character_select.erase("Thea")
		$HP/isi.text = str(thea_unit.hp)
		$EP/isi.text = str(thea_unit.energy)
		print(Profile.character_select)
		$"Button Character 3/CharacterColorBlock3".visible = false


func _on_button_character_4_toggled(button_pressed):
	if(button_pressed):
		$HP/isi.text = str(theon_unit.hp)
		$EP/isi.text = str(theon_unit.energy)
		Profile.character_select.append("Theon")
		_display_splash_art("Theon")
		$"Button Character 4/CharacterColorBlock4".visible = true
		print(Profile.character_select)
	else:
		Profile.character_select.erase("Theon")
		$HP/isi.text = str(theon_unit.hp)
		$EP/isi.text = str(theon_unit.energy)
		print(Profile.character_select)
		$"Button Character 4/CharacterColorBlock4".visible = false




func _on_back_button_pressed():
	Profile.character_select.clear()
	get_tree().change_scene_to_file("res://menu/scenes/select_map_scene.tscn")

