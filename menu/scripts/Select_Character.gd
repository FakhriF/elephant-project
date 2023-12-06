extends Node2D

@onready var next_stage = preload("res://gameStage/MainStage.tscn")
@onready var game_instance = next_stage.instantiate()
@onready var aurel_unit: Unit = game_instance.get_node("GameBoard/Aurel")
@onready var theon_unit: Unit = game_instance.get_node("GameBoard/Theon")
@onready var thea_unit: Unit = game_instance.get_node("GameBoard/Thea")
# Called when the node enters the scene tree for the first time.

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://gameStage/MainStage.tscn")

func _on_button_character_1_toggled(button_pressed):
	if(button_pressed):
		if Profile.character_select.size() < 3:
			$HP/isi.text = str(aurel_unit.hp)
			$EP/isi.text = str(aurel_unit.energy)
			$"Button Character 1/Aurel-splashArt".visible = true
			Profile.character_select.append("Aurel")
			print(Profile.character_select)
		else: 
			print("Maximum Number of Character Selected!")
	else:
		Profile.character_select.erase("Aurel")
		print(Profile.character_select)


func _on_button_character_3_toggled(button_pressed):
	if(button_pressed):
		$HP/isi.text = str(thea_unit.hp)
		$EP/isi.text = str(thea_unit.energy)
		Profile.character_select.append("Thea")
		print(Profile.character_select)
	else:
		Profile.character_select.erase("Thea")
		print(Profile.character_select)


func _on_button_character_4_toggled(button_pressed):
	if(button_pressed):
		$HP/isi.text = str(theon_unit.hp)
		$EP/isi.text = str(theon_unit.energy)
		Profile.character_select.append("Theon")
		print(Profile.character_select)
	else:
		Profile.character_select.erase("Theon")
		print(Profile.character_select)


