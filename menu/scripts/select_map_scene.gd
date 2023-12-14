extends Node2D

@onready var stageBackgroundNodes = get_tree().get_nodes_in_group("Stage Background")
var currentBackgroundIndex = 0
var randomTimer: Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_tree().get_nodes_in_group("StagSelection"):
		button.pressed.connect(func(): call("on_pressed_"+button.name) )
	
	randomTimer = Timer.new()
	add_child(randomTimer)
	randomTimer.timeout.connect(_on_random_background_timer_timeout)
	randomTimer.wait_time = 0.25  # Set the wait time to 1 second
	randomTimer.one_shot = false  # Set to false for repeated calls


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_forest_pressed():
	$RandomStage/Random.text = "[center]Forest"
	Profile.stage_select = "Forest"
	selectBackground(2)


func _on_button_dust_pressed():
	$RandomStage/Random.text = "[center]Desert"
	Profile.stage_select = "Desert"
	selectBackground(0)

func _on_button_snow_pressed():
	$RandomStage/Random.text = "[center]Snow"
	Profile.stage_select = "Snow"
	selectBackground(1)

func _on_button_random_pressed():
	$RandomStage/Random.text = "[center]Random"
	randomTimer.start()
	var stage_options = ["Snow", "Forest", "Desert"]
	Profile.stage_select = stage_options[randi() % stage_options.size()]
	print(Profile.stage_select)


func _on_button_next_pressed():
	if Profile.stage_select == "":
		print("please select a stage first!")
	else:
		get_tree().change_scene_to_file("res://menu/scenes/Select_Character.tscn")

func selectBackground(index):
	randomTimer.stop()
	for i in range(stageBackgroundNodes.size()):
		if i == index:
			stageBackgroundNodes[i].visible = true
		else:
			stageBackgroundNodes[i].visible = false

func selectRandomBackground():
	# Hide all nodes
	for node in stageBackgroundNodes:
		node.visible = false

	if stageBackgroundNodes.size() > 0:
		var randomIndex = randi_range(0, stageBackgroundNodes.size() - 1)
		stageBackgroundNodes[randomIndex].visible = true
	else:
		print("No eligible background nodes found in the group.")

func _on_random_background_timer_timeout():
	selectRandomBackground()
