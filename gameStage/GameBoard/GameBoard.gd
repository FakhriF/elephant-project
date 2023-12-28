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
var _defeatedAlly := {}
var _defeatedEnemy := {}

var _active_unit: Unit
var _target_unit: Unit 
var _walkable_cells := []
var _currentEnemies := []
var ui_initialization = false


@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath

#@onready var CharacterOption = $"../CharacterChoice" 
#@onready var choiceOptionsAdded = false
#@onready var turnChoice = CharacterOption.get_popup()
@onready var Action = ""
@onready var CharacterChoice = $"../ActionMenu"
@onready var enemy_info = $"../CanvasLayer/ColorRect2/Enemy Hp Bar"

var turnManager : TurnManager = TurnManager.new()


func _ready() -> void:
	$"../CanvasLayer/ColorRect".color = "5F94BA"
	if Profile.hasSave:
		print("Hello")
		first_enemy = true   
		first_ally = true
		_load_game()
		print(Profile.character_select)
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
		
func update_unit_UI(unit, index):
	var character_name_path = "../CanvasLayer/ColorRect2/Character Name " + str(index + 1)
	var hp_and_ep_path = "../CanvasLayer/ColorRect2/HP and EP " + str(index + 1)
	var hp_bar_path = "../CanvasLayer/ColorRect2/HP Bar " + str(index + 1)
	var energy_bar_path = "../CanvasLayer/ColorRect2/Energy Bar " + str(index + 1)
	
	
		
	if unit.name == Profile.character_select[index]:
		var character_name = get_node(character_name_path)
		var hp_and_ep = get_node(hp_and_ep_path)
		var hp_bar = get_node(hp_bar_path)
		var energy_bar = get_node(energy_bar_path)
		if turnManager.turnCounter == 1 and ui_initialization == false:
			hp_bar.max_value = unit.hp
			energy_bar.max_value = unit.energy
			ui_initialization = true
		character_name.text = unit.name
		hp_and_ep.text = "HP\t\t%s\nEP\t\t%s" % [str(unit.hp), str(unit.energy)]
		hp_bar.value = unit.hp
		energy_bar.value = unit.energy
		

	
#func process_units():
#	for child in get_children():
#		var unit = child as Unit
#		if unit != null:
#			# Perform actions for valid 'Unit' nodes
#			process_unit(unit)

func _on_ally_turn_started():
	if turnManager.turnCounter == 1:
		$"../CanvasLayer/ColorRect".color = "5F94BA"
	elif turnManager.currentTurn == "Ally Turn":
		$"../CanvasLayer/ColorRect".color = "5F94BA"
	else: 
		$"../CanvasLayer/ColorRect".color = "BA5F6A"
	_playerUnits = _get_ally_unit()
	_enemyUnits = _get_enemy_unit()
	
	for index in range(min(len(Profile.character_select), 3)):
		for child in get_children():
			var unit := child as Unit
			if not unit:
				continue
			update_unit_UI(unit, index)

func _on_enemy_turn_started():
	print("THIS IS ENEMY TURN")
	if turnManager.currentTurn == "Ally Turn":
		$"../CanvasLayer/ColorRect".color = "5F94BA"
	else: 
		$"../CanvasLayer/ColorRect".color = "BA5F6A"
	_playerUnits = _get_ally_unit()
	_enemyUnits = _get_enemy_unit()
	print(_playerUnits)
	print(_enemyUnits)
	_perform_enemy_turn()


func areAllAlliedUnitsDefeated() -> bool:
	for unit in _playerUnits.values():
		if unit.hp > 0:
			return false 
	return true  


# ============================== Turn Manager ==============================

func _get_ally_unit():
	_units.clear()

	for child in get_children():
		var unit := child as Unit
		if not unit:
			continue
		if (unit.name in Profile.character_select) and (unit.hp <= 0):
			if _defeatedAlly.is_empty():
				_defeatedAlly[unit.cell] = unit
			else:
				var isUnique = true
				for unit_info in _defeatedAlly.values():
					var value = str(unit_info)
					var unit_name = value.split(":")[0].strip_edges()
					if unit.name == unit_name:
						isUnique = false
						break
				if isUnique:
					_defeatedAlly[unit.cell] = unit
			print(_defeatedAlly)
#			if _defeatedAlly.size() == Profile.character_select.size():
#				$"../CanvasLayer/BackgroundColor".visible = true
#				$"../CanvasLayer/BackgroundColor/Text".text = "DEFEAT"
		if (unit.name in Profile.character_select) and (unit.hp > 0):
			unit.visible = true
			unit.Turn = true
			if first_ally == false:
				unit.position.x = randi_range(355, 740)
				unit.position.y = randi_range(0, 600)
				unit.cell = grid.calculate_grid_coordinates(unit.position)
				unit.position = grid.calculate_map_position(unit.cell)
				unit.set_aura_color(Color(0, 0, 1, 1))
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
			if eligibleUnits.size() == 0:
				continue
			var randomIndex = randi() % eligibleUnits.size()
				
			var randomUnit = eligibleUnits[randomIndex]
			_get_current_enemies(str(randomUnit.name))  # Corrected to pass the unit name
			
			randomUnit.position.x = randi_range(805, 1125)
			randomUnit.position.y = randi_range(0, 600)
			randomUnit.cell = grid.calculate_grid_coordinates(randomUnit.position)
			randomUnit.position = grid.calculate_map_position(randomUnit.cell)
			_enemyUnits[randomUnit.cell] = randomUnit
#			randomUnit.aura = Color(1, 0, 0, 1)
			randomUnit.set_aura_color(Color(1, 0, 0, 1))
			randomUnit.visible = true
#			randomUnit.material.set("shader_parameter/aura_color", Color(1, 0, 0, 1))
			# Remove the selected unit from eligibleUnits
			eligibleUnits.remove_at(randomIndex)
			
	else:
		for child in get_children():
			var unit := child as Unit
			if not unit or unit.name in Profile.character_select:
				continue
			if (unit.name in _currentEnemies) and (unit.hp <= 0):
				if _defeatedEnemy.is_empty():
					_defeatedEnemy[unit.cell] = unit
				else:
					var isUnique = true
					for unit_info in _defeatedEnemy.values():
						var value = str(unit_info)
						var unit_name = value.split(":")[0].strip_edges()
						if unit.name == unit_name:
							isUnique = false
							break
					if isUnique:
						_defeatedEnemy[unit.cell] = unit
			elif unit.name in _currentEnemies:
				_enemyUnits[unit.cell] = unit
		

		
	
	first_enemy = true
	return _enemyUnits


func _on_end_turn_pressed():
	$"../SkillMenu".visible = false
	CharacterChoice.visible = false
	#Cek apakah masih ada ally tersisa atau tidak (TEMP)
	if _playerUnits == {}:
		_is_victory_defeat("DEFEAT")
	#Cek apakah masih ada musuh tersisa atau tidak (TEMP)
	elif _enemyUnits == {}:
		_is_victory_defeat("VICTORY")
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
	
	if _active_unit.Turn == false:
		_deselect_active_unit()
		_clear_active_unit()
		return
		
	_unit_overlay.draw([Vector2(_active_unit.cell.x, _active_unit.cell.y)], "Ally")
	_active_unit.is_selected = true
	
	CharacterChoice.position = Vector2(_active_unit.position.x + 50, _active_unit.position.y - 75)
	CharacterChoice.visible = true
	Action = "Select Unit"
#	var popupMenu = CharacterOption.get_popup()
#	var theme = popupMenu.get_theme()
#	theme.set_color("font_color", Color(1, 0, 0)) # Change font color to red
#	theme.set_color("background_color", Color(0.2, 0.2, 0.2)) # Change background color
#	# Apply the modified theme
#	popupMenu.set_theme(theme)
#
#
#	CharacterOption.show_popup()
#	_activate_choice(_active_unit)
#	turnChoice.id_pressed.connect(Callable(_on_ally_choice).bind(_active_unit))

func attack(target):
	target.take_damage(10)
#	target.hurt_anim()
	
func use_skill(ally, target, skillName):
	if _active_unit.skill in _active_unit.offensiveSkill:
		_active_unit.useOffensiveSkill(ally, target, _active_unit.skill)
	elif _active_unit.skill in _active_unit.defensiveSkill:
		_active_unit.useSupportSKill(ally, target, _active_unit.skill)



func _on_move_button_pressed():
	print("MOVE UNIT: ", _active_unit)
	Action = "Move"
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells, "Ally")
	_unit_path.initialize(_walkable_cells)
	CharacterChoice.visible = false
	
	
func _on_attack_button_pressed():
	print(_active_unit)
	
	_unit_overlay.draw([Vector2(_active_unit.cell.x + 1, _active_unit.cell.y)], "Attack")
	if is_occupied_by_(Vector2(_active_unit.cell.x + 1, _active_unit.cell.y), "Enemy"):
		Action = "Attack"
		print("You Can Attack!")
		var enemyUnit = get_target(Vector2(_active_unit.cell.x + 1, _active_unit.cell.y), "Enemy")
		$"../CanvasLayer/ColorRect2/Enemy Hp Bar".value = enemyUnit.hp
		$"../CanvasLayer/ColorRect2/Enemy Hp Bar".position = Vector2(enemyUnit.position.x - 15, enemyUnit.position.y - 230)
		$"../CanvasLayer/ColorRect2/Enemy Hp Bar".visible = true
	else:
		Action = "No Enemy"
		print("You Can't Attack")
#	_deselect_active_unit()
#	_clear_active_unit()
		
	CharacterChoice.visible = false

func _on_skill_button_pressed():
	Action = "Skill"
	$"../SkillMenu".position = Vector2(_active_unit.position.x + 160, _active_unit.position.y - 50)
	$"../SkillMenu".visible = true
	$"../SkillMenu/Control/CharacterAction/UseSkill".text = _active_unit.skill
	$"../SkillMenu/Control/CharacterAction/UseUltimate".text = _active_unit.ultimate

	_show_information(_active_unit.name)

func _show_information(unitName: String):
	if unitName == "Aurel":
		$"../SkillMenu/Control/CharacterAction/UseSkill".tooltip_text = "Damage Selected Enemy by 25 HP" 
		$"../SkillMenu/Control/CharacterAction/Skill Energy".text = str(50) + str(" EP")
		$"../SkillMenu/Control/CharacterAction/UseUltimate".tooltip_text = "Damage All Enemy by 75 HP" 
		$"../SkillMenu/Control/CharacterAction/Ultimate Energy".text = str(100) + str(" EP")
	elif unitName == "Theon":
		$"../SkillMenu/Control/CharacterAction/UseSkill".tooltip_text = "Damage Selected Enemy by 25, Heal Selected Character by 25 HP" 
		$"../SkillMenu/Control/CharacterAction/Skill Energy".text = str(25) + str(" EP")
		$"../SkillMenu/Control/CharacterAction/UseUltimate".tooltip_text = "Damage All Enemy by 50 HP, Heal Selected Character by 50 HP" 
		$"../SkillMenu/Control/CharacterAction/Ultimate Energy".text = str(100) + str(" EP")
	elif unitName == "Thea":
		$"../SkillMenu/Control/CharacterAction/UseSkill".tooltip_text = "Heal Selected Ally by 25 HP" 
		$"../SkillMenu/Control/CharacterAction/Skill Energy".text = str(50) + str(" EP")
		$"../SkillMenu/Control/CharacterAction/UseUltimate".tooltip_text = "Heal All Ally by 50 HP" 
		$"../SkillMenu/Control/CharacterAction/Ultimate Energy".text = str(100) + str(" EP")

func _on_use_skill_pressed():
	if _active_unit._check_energy(_active_unit, _active_unit.skill, "Skill"):
		Action = "Use Skill"
		var enemyUnit = get_target(Vector2(_active_unit.cell.x + 1, _active_unit.cell.y), "Enemy")
		
		if _active_unit.skill in _active_unit.offensiveSkill and get_target(Vector2(_active_unit.cell.x + 1, _active_unit.cell.y), "Enemy"):
			enemy_info.value = enemyUnit.hp
			enemy_info.position = Vector2(enemyUnit.position.x - 15, enemyUnit.position.y - 230)
			enemy_info.visible = true
	else:
		print("You have less energy required, please wait to recharge")
		_active_unit.Turn = true
		_deselect_active_unit()
		_clear_active_unit()
	
	$"../SkillMenu".visible = false
	CharacterChoice.visible = false
	
func _on_use_ultimate_pressed():
	if _active_unit.energy < 100:
		_active_unit.Turn = true
		_deselect_active_unit()
		_clear_active_unit()

		print("You need to have 100 energy to use Ultimate")
	else:
		_active_unit.energy -= 100
		
		for child in get_children():
			var unit := child as Unit
			if not unit:
				continue
			if unit.name in _currentEnemies and unit.hp > 0 and (_active_unit.name == "Theon" or _active_unit.name == "Aurel"):
				var enemy_info = $"../CanvasLayer/ColorRect2/Enemy Hp Bar".duplicate()
				add_child(enemy_info)
				enemy_info.value = unit.hp
				enemy_info.position = Vector2(unit.position.x - 65, unit.position.y - 100)
				enemy_info.visible = true
				if _active_unit.ultimate == "Bloodmoon Devour":
					unit._drain_animation()
					unit.take_damage(50)
					_active_unit.heal(50)
				if _active_unit.ultimate == "Zeus' Rage":
					unit._lightning_strike_animation()
					unit.take_damage(75)
				await get_tree().create_timer(0.05).timeout
				enemy_info.value = unit.hp
			
				await get_tree().create_timer(0.1).timeout	
				enemy_info.visible = false
				
				if unit.hp <= 0:
					unit.visible = false
				
					
			
		for index in range(min(len(Profile.character_select), 3)):
			for child in get_children():
				var unit := child as Unit
				if not unit:
					continue
				if unit.name in Profile.character_select:
					if _active_unit.ultimate == "Requiem":
						unit.heal(50)
						unit._heal_animation()
				update_unit_UI(unit, index)
	$"../SkillMenu".visible = false
	CharacterChoice.visible = false
	_active_unit.Turn = false
	_deselect_active_unit()
	_clear_active_unit()
	Action = ""
				
func _on_cancel():
	CharacterChoice.visible = false
	$"../SkillMenu".visible = false
	_deselect_active_unit()
	_clear_active_unit()
	Action = ""
	
func _on_choice_end():
	_active_unit.Turn = false
	_deselect_active_unit()
	_clear_active_unit()
	Action = ""
	




	
func useUltimate(skillName: String):
	if skillName == "Bloodmoon Devour":
		for unit in _enemyUnits:
			print(unit)
#		ally.hp -= 25
		pass
		
#func _on_ally_choice(id, unit_to_take_action):
#	print("Unit to take action is: ", unit_to_take_action)
#	match id:
#		0:
#			print("Hello")
#		1:
#			print("Attack!")
#	turnChoice.id_pressed.disconnect(_on_ally_choice)
#
#func _activate_choice(_active_unit):
#	if not choiceOptionsAdded:
#		turnChoice.add_item("Attack")
#		turnChoice.add_item("Skill")
#		turnChoice.add_item("Move")
#
#		choiceOptionsAdded = true

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
		print("You Selected Unit")
		return
	elif _active_unit.is_selected and (Action == "Select Unit" or Action == "Skill"):
		_on_cancel()
		return
	elif _active_unit.is_selected and _active_unit.Turn == false:
		print("Can't select this Character Again for this Turn")
	elif _active_unit.is_selected and Action == "Attack":
		if is_occupied(cell):
			print("Ally Turn: You Selected Attack")
			var enemyUnit = get_target(cell, "Enemy")
			attack(enemyUnit)
			$"../CanvasLayer/ColorRect2/Enemy Hp Bar".value = enemyUnit.hp
			if enemyUnit.hp <= 0:
				enemyUnit.death()
				await get_tree().create_timer(0.5).timeout
				enemyUnit.visible = false
			else:
				await get_tree().create_timer(0.5).timeout
			$"../CanvasLayer/ColorRect2/Enemy Hp Bar".visible = false
		else: 
			return
		
	elif _active_unit.is_selected and Action == "Use Skill":
#		_active_unit.skillManager(_active_unit.skill)
		if is_occupied(cell):
			if _active_unit.skill in _active_unit.offensiveSkill:
				var enemyUnit = get_target(cell, "Enemy")
				var selectedUnit = get_target(_active_unit.cell, "Ally")
				use_skill(selectedUnit, enemyUnit, _active_unit.skill)
				$"../CanvasLayer/ColorRect2/Enemy Hp Bar".value = enemyUnit.hp
				if enemyUnit.hp <= 0:
					enemyUnit.visible = false
				else:
					await get_tree().create_timer(0.5).timeout
				$"../CanvasLayer/ColorRect2/Enemy Hp Bar".visible = false
			elif _active_unit.skill in _active_unit.defensiveSkill:
				var allyUnit = get_target(cell, "Ally")
				var selectedUnit = get_target(_active_unit.cell, "Ally")
				use_skill(selectedUnit, allyUnit, _active_unit.skill)
		else:
			return

			
	elif _active_unit.is_selected and Action == "No Enemy":
		print("There's No Enemy To Attack")
	elif _active_unit.is_selected and Action == "Move":
		if cell not in get_walkable_cells(_active_unit):
			return
		
		print("Ally Turn: You Selected Movement")
		_move_active_unit(cell)
		
		# Make sure to check if the target cell is occupied by an ally unit
		if is_occupied_by_(cell, "Ally"):
			print("Target cell is occupied by an ally unit. Cannot move.")
			_deselect_active_unit()
			_clear_active_unit()
			return
		_units.erase(_active_unit.cell)
		
		if _units.is_empty():
			print("Can't select any more characters, please end turn")
		return
	for index in range(min(len(Profile.character_select), 3)):
		for child in get_children():
			var unit := child as Unit
			if not unit:
				continue
			update_unit_UI(unit, index)
			
	_on_choice_end()
	#Action = ""
	

# ...

func is_occupied_by_(cell: Vector2, unitType: String) -> bool:
	if unitType == "Ally":
		return _playerUnits.has(cell)
	elif unitType == "Enemy":
		return _enemyUnits.has(cell)
	else:
		return false

# ============================== Enemy Action ==============================


func _perform_enemy_turn() -> void:
	var enemy_units = _enemyUnits.values()
	var player_units = _playerUnits.values()
	for unit in enemy_units:
		_walkable_cells = get_walkable_cells(unit)
		_unit_overlay.draw(_walkable_cells, "Enemy")
		_unit_path.initialize(_walkable_cells)
		var target_cell = calculate_enemy_target(unit, _playerUnits)  # Implement your logic to calculate the target cell.
		print(target_cell)
		var move_delay = 0.5
		if target_cell in _walkable_cells:
			if is_occupied(target_cell):
				target_cell.x -= 1
				var unit_target = get_target(target_cell, "Ally")
				attack(unit_target)
				print("Enemy Turn: Enemy Attacked")
				if (unit_target.hp <= 0):
					unit_target.hp = 0
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





func get_target(cell: Vector2, type: String) -> Unit:
	if is_occupied(cell):
		if type == "Ally":
			_target_unit = _units[cell]
		elif type == "Enemy":
			_target_unit = _enemyUnits[cell]
		return _target_unit
	else:
		return null


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
	_active_unit.Turn = false
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	_clear_active_unit()
	Action = ""
		

## Updates the interactive path's drawing if there's an active and selected unit.
func _on_Cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected and Action == "Move":
		_unit_path.draw_path(_active_unit.cell, new_cell)

# ============================== System ==============================

func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):
		
		if $"../SkillMenu".visible == true:
			$"../SkillMenu".visible = false
			CharacterChoice.visible = true
			Action = ""
			return
		else:
			CharacterChoice.visible = false
		
		enemy_info.visible = false
		_active_unit.is_selected = false
		_deselect_active_unit()
		_clear_active_unit()
		Action = ""


func _save_game():
	var saveName
	var idx
	match Profile.gameProgress:
		"Profile 1":
			saveName = "res://savegame1.bin"
			idx = 0
		"Profile 2":
			saveName = "res://savegame2.bin"       
			idx = 1
		"Profile 3":
			saveName = "res://savegame3.bin"
			idx = 2

	var file = FileAccess.open(saveName, FileAccess.READ_WRITE)

	if file:
		var fileContents = file.get_as_text()
		file.close()

		# Construct the save data
		var saveData: Dictionary = {
			"username": Profile.profileList[idx],
			"characterSelect": Profile.character_select,
			"enemySelection": _currentEnemies,  
			"gameData": {
				"stageSelect": Profile.stage_select,
				"turnCounter": turnManager.turnCounter,
				"currentTurn": turnManager.currentTurn,
				"unitData": [],
				"enemyData": [],
				"defeatedAllies": _defeatedAlly,
				"defeatedEnemies": _defeatedEnemy  
			}
		}

		# Collect data for each unit
		for unit in _playerUnits.values():
			var unitData: Dictionary = {
				"name": unit.name,
				"cell": str(unit.cell),  # Convert Vector2 to string for JSON
				"pos_x": unit.position.x,
				"pos_y": unit.position.y,
				"hp": unit.hp,
				"ep": unit.energy,
				"ally_aura": unit.get_aura_color()
			}
			saveData["gameData"]["unitData"].append(unitData)
		
		for enemyUnit in _enemyUnits.values():
			var enemyInfo: Dictionary = {
				"enemy_name": enemyUnit.name,
				"cell": str(enemyUnit.cell),
				"pos_x": enemyUnit.position.x,
				"pos_y": enemyUnit.position.y,
				"hp": enemyUnit.hp,
				"ep": enemyUnit.energy,
				"enemy_aura": enemyUnit.get_aura_color()
			}
			saveData["gameData"]["enemyData"].append(enemyInfo)

		# Convert saveData to JSON format
		var saveString = JSON.stringify(saveData)

		# Write the save data to the file
		file = FileAccess.open(saveName, FileAccess.WRITE)

		if file:
			file.store_string(saveString)
			file.close()
			print("Game saved successfully.")
		else:
			print("Error opening file.")
	else:
		print("Error reading file.")
		
func get_unit_at_cell(cell: Vector2) -> Unit:
	# Iterate through all units and find the one at the specified cell
	for child in get_children():
		var unit = child as Unit
		if not unit:
			continue
		if (unit.name in Profile.character_select) and (unit.hp > 0):
			return unit

	# Return null if no unit is found at the specified cell
	return null
	
func find_unit_by_name(name: String) -> Unit:
	# Iterate through all units and find the one with the specified name
	for child in get_children():
		var unit = child as Unit
		if unit and unit.name == name:
			return unit

	# Return null if no unit is found with the specified name
	return null


# Function to initialize or update units based on loaded data
func initialize_or_update_unit(cell: Vector2, name: String, hp: int, ep: int, posX: float, posY: float, type: String, aura_color: Color) -> void:

	var unitToUpdate = find_unit_by_name(name)
	if unitToUpdate != null && hp > 0:
		unitToUpdate.cell = cell
		unitToUpdate.name = name
		unitToUpdate.hp = hp
		unitToUpdate.energy = ep
		unitToUpdate.position.x = posX
		unitToUpdate.position.y = posY
		unitToUpdate.cell = grid.calculate_grid_coordinates(unitToUpdate.position)
		unitToUpdate.position = grid.calculate_map_position(unitToUpdate.cell)
		
		unitToUpdate.set_aura_color(Color(aura_color))
		if type == "Ally":
			_playerUnits[unitToUpdate.cell] = unitToUpdate  # Add or update the unit in _playerUnits
			_units[unitToUpdate.cell] = unitToUpdate
		elif type == "Enemy":
			_enemyUnits[unitToUpdate.cell] = unitToUpdate
			unitToUpdate.visible = true
			

			

# Function to convert cell string to Vector2
func parse_cell_string(cellStr: String) -> Vector2:
	var coordinates = cellStr.split(",")
	return Vector2(float(coordinates[0]), float(coordinates[1]))

func parse_string_color(colorString: String) -> Color:
	var openParenIndex = colorString.find("(")
	var closeParenIndex = colorString.find(")")
	
	if openParenIndex == -1 or closeParenIndex == -1:
		return Color(0, 0, 0, 1) # Return default color if the format is incorrect
	
	var colorValuesString = colorString.substr(openParenIndex + 1, closeParenIndex - openParenIndex - 1)
	var colorComponents = colorValuesString.split(",")
	
	if colorComponents.size() < 4:
		return Color(0, 0, 0, 1) # Return default color if insufficient components
	
	return Color(
		float(colorComponents[0]),
		float(colorComponents[1]),
		float(colorComponents[2]),
		float(colorComponents[3])
	)


func _load_game():
	var saveName
	match Profile.gameProgress:
		"Profile 1":
			saveName = "res://savegame1.bin"
		"Profile 2":
			saveName = "res://savegame2.bin"       
		"Profile 3":
			saveName = "res://savegame3.bin"

	var file = FileAccess.open(saveName, FileAccess.READ)
	
	if file:
		var fileContents = file.get_as_text()
		file.close()

		var jsonData = JSON.parse_string(fileContents)

		if jsonData.has("username"):
			Profile.profileList = jsonData["username"]

		if jsonData.has("characterSelect") && jsonData.has("enemySelection") :
			Profile.character_select = jsonData["characterSelect"]
			_currentEnemies = jsonData["enemySelection"]

		if jsonData.has("gameData"):
			var gameData = jsonData["gameData"]
			Profile.stage_select = gameData["stageSelect"]
			if gameData.has("turnCounter"):
				turnManager.turnCounter = gameData["turnCounter"]
				turnManager.currentTurn = gameData["currentTurn"]
				print(gameData["turnCounter"])
				print(turnManager.turnCounter)
				$"../CanvasLayer/TurnCounter".text = "[center][b]Turn %s\n%s[/b][/center]" % [str(turnManager.turnCounter), turnManager.currentTurn]
#			if gameData.has("units"):
#					_units = gameData["units"]
#					print("THIS IS _UNITS")
#					print(_units)
#			if gameData.has("playerUnits"):
#				_playerUnits = gameData["playerUnits"]
#			if gameData.has("enemyUnits"):
#				_enemyUnits = gameData["enemyUnits"]

#			if gameData.has("defeatedUnits"):
#				var loadedDefeatedUnits = gameData["defeatedUnits"]
#				_defeatedAlly.clear()  # Clear the existing defeated units dictionary
#				for key in loadedDefeatedUnits.keys():
#					_defeatedAlly[key] = loadedDefeatedUnits[key]
#				print("DEFEATED :", _defeatedAlly)

			if gameData.has("defeatedAllies"):
				var loadedDefeatedAlly = gameData["defeatedAllies"]
				_defeatedAlly.clear()
				for key in loadedDefeatedAlly.keys():
					_defeatedAlly[key] = loadedDefeatedAlly[key]
				print("DEFEATED :", _defeatedAlly)
				for unit_info in _defeatedAlly.values():
					var unit_name = unit_info.split(":")[0].strip_edges()
					print("Unit Name:", unit_name)
					for child in get_children():
						var unit := child as Unit
						if not unit:
							continue
						if unit.name == unit_name:
							unit.hp = 0
							_units.erase(unit.cell)
							
			if gameData.has("defeatedEnemies"):
				var loadedDefeatedEnemy = gameData["defeatedEnemies"]
				_defeatedEnemy.clear()
				for key in loadedDefeatedEnemy.keys():
					_defeatedEnemy[key] = loadedDefeatedEnemy[key]
				print("DEFEATED :", _defeatedEnemy)
				for unit_info in _defeatedEnemy.values():
					var unit_name = unit_info.split(":")[0].strip_edges()
					print("Unit Name:", unit_name)
					for child in get_children():
						var unit := child as Unit
						if not unit:
							continue
						if unit.name == unit_name:
							unit.hp = 0
							_units.erase(unit.cell)



			if gameData.has("unitData"):
				var unitData = gameData["unitData"]
				for unitInfo in unitData:
					if unitInfo.has("cell") and unitInfo.has("hp"):
						var unitName = unitInfo["name"]
						var cellStr = unitInfo["cell"]
						var pos_x = unitInfo["pos_x"]
						var pos_y = unitInfo["pos_y"]
						var hp = unitInfo["hp"]
						var ep = unitInfo["ep"]
						var aura_color = unitInfo["ally_aura"]
						var auraColor = parse_string_color(aura_color)
						print("NAME", unitName, hp, auraColor)
						var cell = parse_cell_string(cellStr)  # Function to convert string to Vector2
						initialize_or_update_unit(cell, unitName, hp, ep, pos_x, pos_y, "Ally", auraColor) 
			
			if gameData.has("enemyData"): 
				var enemyData = gameData["enemyData"]
				for enemyInfo in enemyData:
					if enemyInfo.has("cell") and enemyInfo.has("hp"):
						var name = enemyInfo["enemy_name"]
						var cellStr = enemyInfo["cell"]
						var pos_x = enemyInfo["pos_x"]
						var pos_y = enemyInfo["pos_y"]
						var hp = enemyInfo["hp"]
						var ep = enemyInfo["ep"]
						var aura_color = enemyInfo["enemy_aura"]
						var auraColor = parse_string_color(aura_color)
						var cell = parse_cell_string(cellStr)  # Function to convert string to Vector2
						initialize_or_update_unit(cell, name, hp, ep, pos_x, pos_y, "Enemy", auraColor)  
				print("Game loaded successfully.")



	
func _is_victory_defeat(status):
	$"../VictoryDefeat".visible = true
	if status == "VICTORY":
		$"../VictoryDefeat/Label".add_theme_color_override("font_color", Color("ffe3ac"))
		$"../VictoryDefeat/Label".text = "VICTORY"
	elif status == "DEFEAT":
		$"../VictoryDefeat/Label".add_theme_color_override("font_color", Color("ffacac"))
		$"../VictoryDefeat/Label".text = "DEFEAT"

func _on_exitto_menu_pressed():
	get_tree().change_scene_to_file("res://menu/scenes/main_menu_scene.tscn")


func _on_button_pressed():
	_save_game() # Replace with function body.


func _on_save_and_exit_button_pressed():
	_save_game() 
	get_tree().quit()

func _on_load_game_pressed():
	_load_game()


func _on_pause_button_pressed():
	$"../Pause Canvas".visible = true


func _on_pause_back_button_pressed():
	$"../Pause Canvas".visible = false










