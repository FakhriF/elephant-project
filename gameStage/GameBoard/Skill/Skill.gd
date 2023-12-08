class_name Skill
extends Resource

@export var name: String
@export var cost: int
@export var power: int
@export var heal: int
@export var targetType: int

func calculate_damage(stat, def: int) -> int:
	var x : int = (power * stat) - def
	if x <= 0:
		return 1
	else:
		return x 
