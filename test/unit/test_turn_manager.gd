extends "res://addons/gut/test.gd"
var turnManager = load("res://gameStage/GameBoard/TurnManager.gd")
var testTurnManager = null

func before_each():
	testTurnManager = turnManager.new()

func after_each():
	testTurnManager = null

func test_initial_turn():
	assert_eq(testTurnManager.turnCounter, 1, "Initial turn should be Ally Turn")

func test_turn_advancement():
	testTurnManager.advance_turn()
	assert_eq(testTurnManager.currentTurn, "Enemy Turn", "Turn should advance to Enemy Turn")

	testTurnManager.advance_turn()
	assert_eq(testTurnManager.currentTurn, "Ally Turn", "Turn should wrap back to Ally Turn")

