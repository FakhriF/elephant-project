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
	assert_eq(testCharacter.hp, 60, "HP should be 90!")
	
func test_useOffensiveSkill():
	testCharacter.energy = 50

	var targetUnit = Character.new()  # Changed 'Unit.new()' to 'Character.new()'
	targetUnit.hp = 100
	
	testCharacter.skill = "Drain"
	testCharacter.useOffensiveSkill(testCharacter, targetUnit, "Drain")
	
	# Check if the Drain skill properly decreases the energy and damages the target
	assert_eq(testCharacter.energy, 0, "Energy should be 0 after using Drain skill")
	assert_eq(targetUnit.hp, 75, "Target's HP should decrease to 75 after using Drain skill")

	testCharacter.energy = 50
	targetUnit.hp = 100
	# Use the offensive skill "Midas Touch" on the target unit
	testCharacter.skill = "Midas Touch"
	testCharacter.useOffensiveSkill(testCharacter, targetUnit, "Midas Touch")

	# Check if the Midas Touch skill properly decreases the energy and damages the target
	assert_eq(testCharacter.energy, 25, "Energy should be 0 after using Midas Touch as an offensive skill")
	assert_eq(targetUnit.hp, 75, "Target's HP should decrease to 50 after using Midas Touch as an offensive skill")
	
func test_useDefensiveSkill():
	testCharacter.energy = 50
	
	# Create an ally unit
	var allyUnit = Character.new()
	allyUnit.hp = 50
	
	# Set the skill of the test character to "Heal"
	testCharacter.skill = "Heal"
	
	# Use the defensive skill "Heal" on the ally unit
	testCharacter.useSupportSKill(testCharacter, allyUnit, "Heal")
	
	# Check if the Heal skill properly decreases the energy and heals the ally
	assert_eq(testCharacter.energy, 0, "Energy should be 0 after using Heal as a defensive skill")
	assert_eq(allyUnit.hp, 75, "Ally's HP should increase to 75 after using Heal as a defensive skill")

