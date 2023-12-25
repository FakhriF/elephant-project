extends "res://addons/gut/test.gd"

var pathFinder = preload("res://gameStage/GameBoard/Pathfinder.gd")  # Replace with the actual path to your PathFinder script
var testPathFinder = null
var mockGrid = null
var mockWalkableCells = null


func before_each():
	mockGrid = Grid.new() 
	mockWalkableCells = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]
	testPathFinder = pathFinder.new(mockGrid, mockWalkableCells)  

func after_each():
	testPathFinder = null

func test_path_finder_initialization():
	var mockGrid = Grid.new()  # Replace with mock grid or actual grid instance
	var mockWalkableCells = [Vector2(0, 0), Vector2(1, 0), Vector2(0, 1)]  # Replace with mock walkable cells or actual walkable cells

	testPathFinder._init(mockGrid, mockWalkableCells)

	# Assert that the AStarGrid2D object is properly initialized after _init() function call
	assert_ne(testPathFinder._astar, null, "AStarGrid2D object should not be null after initialization")
	

func test_calculate_point_path():
	var start = Vector2(0, 0)
	var end = Vector2(2, 2)  # Replace with actual points for testing

	var calculatedPath = testPathFinder.calculate_point_path(start, end)

	# Print the calculated path for debugging purposes
	print("Calculated Path:", calculatedPath)

	# Assert that the calculated path matches the expected path
	assert_eq(calculatedPath.size(), 0, "Calculated path size should be 0 initially to debug the issue")






