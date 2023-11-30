extends Node2D

@export var timer = 0.2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print(timer)
	if timer >= 0:
		timer -= delta
	else:
		# get_tree().change_scene_to_file("res://menu/scenes/welcome.tscn")
		get_tree().change_scene_to_file("res://menu/scenes/welcome.tscn")
