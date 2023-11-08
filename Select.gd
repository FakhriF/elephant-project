extends Node2D

# Preload the Character script
const Character = preload("res://Class/Character.gd")

var character_1 = Character.new("Character 1", "res://menu/assets/character_1.png", {"HP": 100, "EP": 10})
var character_2 = Character.new("Character 2", "res://menu/assets/character_2.png", {"HP": 300, "EP": 7})
var character_3 = Character.new("Character 3", "res://menu/assets/character_3.png", {"HP": 80, "EP": 25})
var character_4 = Character.new("Character 4", "res://menu/assets/character_4.png", {"HP": 90, "EP": 15})

var start_button
var back_button
var character_box_1
var character_box_2
var character_box_3
var character_box_4
var stats_button_1
var stats_button_2
var stats_button_3
var stats_button_4

var current_character = null

func _ready():
	# Connect the signals to the functions
	start_button.connect("pressed", self, "_on_StartButton_pressed")
	back_button.connect("pressed", self, "_on_BackButton_pressed")
	stats_button_1.connect("pressed", self, "_on_StatsButton_pressed", [character_1])
	stats_button_2.connect("pressed", self, "_on_StatsButton_pressed", [character_2])
	stats_button_3.connect("pressed", self, "_on_StatsButton_pressed", [character_3])
	stats_button_4.connect("pressed", self, "_on_StatsButton_pressed", [character_4])

	# Set the character images
	character_box_1.texture = load(character_1.get_image())
	character_box_2.texture = load(character_2.get_image())
	character_box_3.texture = load(character_3.get_image())
	character_box_4.texture = load(character_4.get_image())
