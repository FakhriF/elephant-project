extends "res://addons/gut/test.gd"

var grid = load("res://gameStage/GameBoard/Grid.gd")
var testGrid = null

func before_each():
	testGrid = grid.new()  # Initialize the Grid instance

func after_each():
	testGrid = null

func test_calculate_map_position():
	var gridPosition = Vector2(2, 3)
	var expectedMapPosition = Vector2(160, 224)  # Replace with the expected map position based on your calculations

	var calculatedMapPosition = testGrid.calculate_map_position(gridPosition)

	# Assert that the calculated map position matches the expected map position
	assert_eq(calculatedMapPosition, expectedMapPosition, "Calculated map position should match expected position")

	# Add more specific assertions related to calculate_map_position() functionality

func test_calculate_grid_coordinates():
	var mapPosition = Vector2(320, 384)
	var expectedGridCoordinates = Vector2(5, 6)  # Replace with the expected grid coordinates based on your calculations

	var calculatedGridCoordinates = testGrid.calculate_grid_coordinates(mapPosition)

	# Assert that the calculated grid coordinates match the expected grid coordinates
	assert_eq(calculatedGridCoordinates, expectedGridCoordinates, "Calculated grid coordinates should match expected coordinates")


func test_is_within_bounds():
	var withinBoundsCoordinates = Vector2(15, 8)
	var outOfBoundsCoordinates = Vector2(20, 12)

	# Assert that the within bounds coordinates return true
	assert(testGrid.is_within_bounds(withinBoundsCoordinates), "Coordinates within bounds should return true")

	# Assert that the out of bounds coordinates return false
	assert_false(testGrid.is_within_bounds(outOfBoundsCoordinates), "Coordinates out of bounds should return false")



func test_grid_clamp():
	var gridPosition = Vector2(-2, 7)
	var expectedClampedPosition = Vector2(5, 7)  # Replace with the expected clamped position based on your calculations

	var clampedPosition = testGrid.grid_clamp(gridPosition)

	# Assert that the clamped position matches the expected clamped position
	assert_eq(clampedPosition, expectedClampedPosition, "Clamped position should match expected position")

