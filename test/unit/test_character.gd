extends "res://addons/gut/test.gd"

var Character = load("res://gameStage/Units/Unit.gd")
var testCharacter = null

func before_each():
	testCharacter = Character.new()

func after_each():
	testCharacter.free()

func test_take_damage():
	testCharacter.hp = 100
	var damage = testCharacter.take_damage(10)
	
	assert_eq(testCharacter.hp, 90, "HP should be 90!")
	
func test_heal():
	testCharacter.hp = 50
	var heal = testCharacter.heal(10)
	assert_eq(testCharacter.hp, 60, "HP should be 60!")
	
	
