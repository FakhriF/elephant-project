extends Node2D

@onready var next_stage = preload("res://gameStage/MainStage.tscn")
@onready var game_instance = next_stage.instantiate()
@onready var aurel_unit: Unit = game_instance.get_node("GameBoard/Aurel")
# Called when the node enters the scene tree for the first time.


func _ready():
	print(aurel_unit)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://gameStage/MainStage.tscn")

func _on_button_character_1_toggled(button_pressed):
	if(button_pressed):
		print("Hello")
		Profile.character_select.append("Aurel")
	else:
		print("Goodbye")  


