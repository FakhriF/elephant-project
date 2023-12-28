extends "res://addons/gut/test.gd"
var gameBoard = load("res://gameStage/GameBoard/GameBoard.gd")
var testGameBoard = null

func before_each():
	testGameBoard = gameBoard.new()

func after_each():
	testGameBoard = null


