
class_name Player

var charName
var description
var appearance
var health
var energy
var movement
var player

var character_name = ""
var character_sprite = null
var character_attributes = {}

# Initialize the character with the provided attributes
func _init(name: String, sprite_path: String, attributes: Dictionary):
	character_name = name
	character_sprite = load(sprite_path)
	character_attributes = attributes

func basic_attack():
	# Add your basic attack logic here
	var enemy_hp = character_attributes["HP"]
	enemy_hp -= 10
	character_attributes["HP"] = enemy_hp
	print("Using Basic Attack skill! Enemy HP: ", enemy_hp)
	

func useSkill():
	pass
