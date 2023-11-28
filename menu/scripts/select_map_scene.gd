extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("StagSelection"):
		button.pressed.connect(func(): call("on_pressed_"+button.name) )


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_forest_pressed():
	Profile.stage_select = "Forest"
	print(Profile.stage_select)


func _on_button_dust_pressed():
	Profile.stage_select = "Desert"

func _on_button_snow_pressed():
	Profile.stage_select = "Snow"


func _on_button_random_pressed():
	var stage_options = ["Snow", "Forest", "Desert"]
	Profile.stage_select = stage_options[randi() % stage_options.size()]
	print(Profile.stage_select)


func _on_button_next_pressed():
	if Profile.stage_select == "":
		print("please select a stage first!")
	else:
		get_tree().change_scene_to_file("res://menu/scenes/Select_Character.tscn")
