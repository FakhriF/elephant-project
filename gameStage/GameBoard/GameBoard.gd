## Represents and manages the game board. Stores references to entities that are in each cell and
## tells whether cells are occupied or not.
## Units can only move around the grid one at a time.
class_name GameBoard
extends Node2D

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

## Resource of type Grid.
@export var grid: Resource

## Mapping of coordinates of a cell to a reference to the unit it contains.
var first_ally := false
var first_enemy := false

var _units := {}
var _playerUnits := {}
var _enemyUnits := {}

var _active_unit: Unit
var _target_unit: Unit 
var _walkable_cells := []
var _currentEnemies := []

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath


var turnManager : TurnManager = TurnManager.new()


func _ready() -> void:
	_check_stage()
	turnManager.ally_turn_started.connect(_on_ally_turn_started)
	turnManager.enemy_turn_started.connect(_on_enemy_turn_started)
	turnManager.start()
	$"../CanvasLayer/TurnCounter".text = "[center][b]Turn %s\n%s[/b][/center]" % [str(turnManager.turnCounter), turnManager.currentTurn]

func _check_stage():
	if Profile.stage_select == "Forest":
		$"../Map".visible = true
	if Profile.stage_select == "Desert":
		$"../Desert".visible = true
	if Profile.stage_select == "Snow":
		$"../Snow".visible = true

func _on_ally_turn_started():
	_playerUnits = _get_ally_unit()
	_enemyUnits = _get_enemy_unit()
	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		if unit.name == Profile.character_select[0]:
			$"../CanvasLayer/ColorRect2/Character Name 1".text = unit.name
			$"../CanvasLayer/ColorRect2/HP and EP".text = "HP\t\t%s\nEP\t\t%s" % [str(unit.hp), str(unit.energy)]
			$"../CanvasLayer/ColorRect2/HP Bar".value = unit.hp
		if unit.name == Profile.character_select[1]:
			$"../CanvasLayer/ColorRect2/Character Name 2".text = unit.name
			$"../CanvasLayer/ColorRect2/HP and EP2".text = "HP\t\t%s\nEP\t\t%s" % [str(unit.hp), str(unit.energy)]
			$"../CanvasLayer/ColorRect2/HP Bar 2".value = unit.hp
		if unit.name == Profile.character_select[2]:
			$"../CanvasLayer/ColorRect2/Character Name 3".text = unit.name
			$"../CanvasLayer/ColorRect2/HP and EP3".text = "HP\t\t%s\nEP\t\t%s" % [str(unit.hp), str(unit.energy)]
			$"../CanvasLayer/ColorRect2/HP Bar 3".value = unit.hp

func _on_enemy_turn_started():
	_playerUnits = _get_ally_unit()
	_enemyUnits = _get_enemy_unit()
	_perform_enemy_turn()
	
func attack(target):
	target.take_damage(10)
	target.hurt_anim()


# ============================== Turn Manager ==============================

func _get_ally_unit():
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		if (unit.name in Profile.character_select) and (unit.hp > 0):
			print(unit)
			unit.visible = true
			if first_ally == false:
				unit.position.x = randi_range(355, 740)
				unit.position.y = randi_range(0, 600)
				unit.cell = grid.calculate_grid_coordinates(unit.position)
				unit.position = grid.calculate_map_position(unit.cell)
			_units[unit.cell] = unit
#			unit.aura = Color(0, 0, 1, 1)
	first_ally = true
	return _units

func _get_current_enemies(unitName: String) -> void:
	if _currentEnemies.size() < 3:
		_currentEnemies.append(unitName)

func _get_enemy_unit() -> Dictionary:
	_enemyUnits.clear()
	var eligibleUnits = []
	
	if first_enemy == false:
		for child in get_children():
			var unit := child as Unit
			if not unit or unit.name in Profile.character_select:
				continue
			eligibleUnits.append(unit)
			
		while _enemyUnits.size() < 3:
			var randomIndex = randi() % eligibleUnits.size()
			var randomUnit = eligibleUnits[randomIndex]
			_get_current_enemies(str(randomUnit.name))  # Corrected to pass the unit name
			
			randomUnit.position.x = randi_range(805, 1125)
			randomUnit.position.y = randi_range(0, 600)
			randomUnit.cell = grid.calculate_grid_coordinates(randomUnit.position)
			randomUnit.position = grid.calculate_map_position(randomUnit.cell)
			_enemyUnits[randomUnit.cell] = randomUnit
#			randomUnit.aura = Color(1, 0, 0, 1)
			randomUnit.visible = true
			# Remove the selected unit from eligibleUnits
			eligibleUnits.remove_at(randomIndex)
			
	else:
		for child in get_children():
			var unit := child as Unit
			if not unit or unit.name in Profile.character_select:
				continue
			if unit.name in _currentEnemies:
				_enemyUnits[unit.cell] = unit
		

		
	
	first_enemy = true
	return _enemyUnits
	

func _on_end_turn_pressed():
	_playerUnits.clear()
	_units.clear()
	_enemyUnits.clear()
	turnManager.advance_turn()
	$"../CanvasLayer/TurnCounter".text = "[center][b]Turn %s\n%s[/b][/center]" % [str(turnManager.turnCounter), turnManager.currentTurn]

# ============================== Player Action ==============================
## Selects the unit in the `cell` if there's one there.
## Sets it as the `_active_unit` and draws its walkable cells and interactive move path. 
func _select_unit(cell: Vector2) -> void:
	if not _units.has(cell):
		return
	
	_active_unit = _units[cell]
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)


## Deselects the active unit, clearing the cells overlay and interactive path drawing.
func _deselect_active_unit() -> void:
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


## Clears the reference to the _active_unit and the corresponding walkable cells.
func _clear_active_unit() -> void:
	_active_unit = null
	_walkable_cells.clear()

## Selects or moves a unit based on where the cursor is.
func _on_Cursor_accept_pressed(cell: Vector2) -> void:
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)
		
		# Make sure to check if the target cell is occupied by an ally unit
		if is_occupied_by_ally(cell):
			print("Target cell is occupied by an ally unit. Cannot move.")
			_deselect_active_unit()
			_clear_active_unit()
			return

		# Make it so that the unit can only move once
		_units.erase(_active_unit.cell)
		
		if _units.is_empty():
			print("Can't select any more characters, please end turn")

# ...

func is_occupied_by_ally(cell: Vector2) -> bool:
	return _playerUnits.has(cell)

# ============================== Enemy Action ==============================


func _perform_enemy_turn() -> void:
	var enemy_units = _enemyUnits.values()
	var player_units = _playerUnits.values()
	print("Turn Enemy")
	for unit in enemy_units:
		_walkable_cells = get_walkable_cells(unit)
		_unit_overlay.draw(_walkable_cells)
		_unit_path.initialize(_walkable_cells)
		var target_cell = calculate_enemy_target(unit, _playerUnits)  # Implement your logic to calculate the target cell.
		print(target_cell)
		var move_delay = 0.5
		if target_cell in _walkable_cells:
			if is_occupied(target_cell):
				target_cell.x -= 1
				var unit_target = get_target(target_cell)
				attack(unit_target)
				print("Bisa Nyerang")
				if (unit_target.hp <= 0):
					unit_target.visible = false
				_unit_overlay.clear()
				_unit_path.stop()
				continue
			else:
				print("Bisa Bergerak")
				await _delayed_enemy_movement(unit, target_cell, move_delay)
		else:
			print("Tidak bisa bergerak")
			await _delayed_enemy_movement(unit, _walkable_cells[randi_range(0, _walkable_cells.size() - 1)], move_delay)
		_enemyUnits.erase(unit.cell) 
	turnManager.advance_turn()
	$"../CanvasLayer/TurnCounter".text = "[center][b]Turn %s\n%s[/b][/center]" % [str(turnManager.turnCounter), turnManager.currentTurn]


func _delayed_enemy_movement(unit, target, delay):
	await get_tree().create_timer(delay).timeout

	if is_occupied(target) or not target in _walkable_cells or target == unit.cell:
		return

	# Remove the unit from its current cell in _enemyUnits
	_enemyUnits.erase(unit.cell)

	# Update the unit's cell to the new target cell
	unit.cell = target

	# Add the unit to the new cell in _enemyUnits
	_enemyUnits[target] = unit

	# Calculate the path to the target cell
	var path_to_target = [unit.cell, target]  # Create a path with only two points: the unit's current cell and the target cell
	_unit_overlay.clear()
	_unit_path.stop()
	# Set the unit's path and make it start moving
	unit.walk_along(path_to_target)

	# Wait for the unit to finish moving
	await unit.walk_finished
	_clear_active_unit()


func calculate_enemy_target(enemy_unit: Unit, player_units: Dictionary) -> Vector2:
	var nearest_distance = float("inf")
	var nearest_target: Vector2 = Vector2.ZERO

	for player_unit in player_units.values():
		var player_cell = player_unit.cell
		var enemy_cell = enemy_unit.cell
		var distance = enemy_cell.distance_to(player_cell)

		print("Player Cell:", player_cell, "Distance:", distance)

#		if distance < nearest_distance:
		nearest_distance = distance
		nearest_target = player_cell

	# Adjust the nearest_target if it's occupied
	if is_occupied(nearest_target):
		nearest_target.x += 1

	if nearest_target != Vector2.ZERO:
		print("Selected Target:", nearest_target)
		return nearest_target
	else:
		print("No valid target found")
		return Vector2.ZERO





func get_target(cell: Vector2) -> Unit:
	_target_unit = _units[cell]
	return _target_unit


func areCharactersNextToEachOther(character1_position, character2_position):
	if abs(character1_position.x - character2_position.x) <= 1 && abs(character1_position.y - character2_position.y) == 0 || abs(character1_position.y - character2_position.y) <= 1 && abs(character1_position.x - character2_position.x) == 0:
		return true
	else:
		return false
	
# ============================== Movement ==============================


## Returns `true` if the cell is occupied by a unit.
func is_occupied(cell: Vector2) -> bool:
	return _units.has(cell) or _enemyUnits.has(cell)


## Returns an array of cells a given unit can walk using the flood fill algorithm.
func get_walkable_cells(unit: Unit) -> Array:
	return _flood_fill(unit.cell, unit.move_range)


## Returns an array with all the coordinates of walkable cells based on the `max_distance`.
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			# Minor optimization: If this neighbor is already queued
			#	to be checked, we don't need to queue it again
			if coordinates in stack:
				continue

			stack.append(coordinates)
	return array


## Updates the _units dictionary with the target position for the unit and asks the _active_unit to walk to it.
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	# warning-ignore:return_value_discarded
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_clear_active_unit()
		

## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)

# ============================== System ==============================

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning

func _save_game():
	var saveName
	match Profile.gameProgress:
		"Profile 1":
			saveName = "res://savegame1.bin"
		"Profile 2":
			saveName = "res://savegame2.bin"
		"Profile 3":
			saveName = "res://savegame3.bin"
	var file = FileAccess.open(saveName, FileAccess.WRITE)

	var saveData: Dictionary = {
			"units": _units,
			"playerUnits": _playerUnits,
			"turnManager": turnManager
		}

	
