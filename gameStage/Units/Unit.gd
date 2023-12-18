## Represents a unit on the game board.
## The board manages its position inside the game grid.
## The unit itself holds stats and a visual representation that moves smoothly in the game world.
@tool
class_name Unit
extends Path2D

## Emitted when the unit reached the end of a path along which it was walking.
signal walk_finished
signal dead
signal health_changed(life)

## Shared resource of type Grid, used to calculate map coordinates.
@export var grid: Resource
## Distance to which the unit can walk in cells.
@export var move_range := 6
## The unit's move speed when it's moving along a path.
@export var move_speed := 600.0

@export var hp := 100
@export var energy := 100

@export var Turn := true

@export var skill := ""
@export var ultimate := ""

@onready var offensiveSkill := ["Midas Touch", "Drain"]
@onready var defensiveSkill := ["Heal"]


func _hurt_animation():
	_aura.visible = false
	_sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	_sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.05).timeout
	_sprite.modulate = Color.RED
	await get_tree().create_timer(0.05).timeout
	_sprite.modulate = Color.WHITE
	await get_tree().create_timer(0.1).timeout
	_sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	_sprite.modulate = Color.WHITE
	_aura.visible = true

func take_damage(damage):
	
	hp = hp - damage
	_hurt_animation()
	if hp <= 0:
		emit_signal("dead")
	else:
		emit_signal("health_changed", hp)
	
func heal(amount):
	hp += amount
	hp = clamp(hp, hp, 100)
	emit_signal("health_changed", hp)

func skillManager(skillName: String):
	if skillName in offensiveSkill:
#		useOffensiveSkill(skillName)
		pass
	elif skillName in defensiveSkill:
#		useSupportSKill(skillName)
		pass
		

func useOffensiveSkill(ally, target, skillName: String):
	if skillName == "Midas Touch":
		ally.energy -= 25
		target.take_damage(25)
	elif skillName == "Drain":
		ally.energy -= 50
		ally.heal(25)
		target.take_damage(25)
		

func useSupportSKill(ally, skillName: String):
	if skillName == "Heal":
		ally.energy -= 50
		heal(25)
	# Requiem - > Mass Heal Ultimate

func display_aura(status: bool):
	var sprite_material = _aura.material
	sprite_material.set_shader_parameter("aura_visible", status)

func set_aura_color(new_color: Color) -> void:
	_aura.texture = _sprite.texture
	var sprite_material = _aura.material
	sprite_material.set_shader_parameter("aura_color", new_color)

func get_aura_color() -> Color:
	var sprite_material = _aura.material
	return sprite_material.get_shader_parameter("aura_color")


	
	
## Texture representing the unit.
@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
			# This will resume execution after this node's _ready()
			await ready
		_sprite.texture = value
		
## Offset to apply to the `skin` sprite in pixels.
@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

#@export var aura: Color:
#	set(value):
#		aura = value
#		if not _sprite:
#			# This will resume execution after this node's _ready()
#			await ready
#		_sprite.material.set("shader_param/aura_color", value) 

## Coordinates of the current cell the cursor moved to.
var cell := Vector2.ZERO:
	set(value):
		# When changing the cell's value, we don't want to allow coordinates outside
		#	the grid, so we clamp them
		cell = grid.grid_clamp(value)
## Toggles the "selected" animation on the unit.
var is_selected := false:
	set(value):
		is_selected = value
		if is_selected:
			_anim_player.play("selected")
		else:
			_anim_player.play("idle")

var _is_walking := false:
	set(value):
		_is_walking = value
		set_process(_is_walking)

@onready var _sprite: Sprite2D = $PathFollow2D/Sprite
@onready var _aura: Sprite2D = $PathFollow2D/Sprite/Aura
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D

@onready var _anim = get_node("AnimationPlayer")





func _ready() -> void:
	set_process(false)
	_path_follow.rotates = false

	cell = grid.calculate_grid_coordinates(position)
	position = grid.calculate_map_position(cell)

	# We create the curve resource here because creating it in the editor prevents us from
	# moving the unit.
	if not Engine.is_editor_hint():
		curve = Curve2D.new()


func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta

	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		# Setting this value to 0.0 causes a Zero Length Interval error
		_path_follow.progress = 0.00001
		position = grid.calculate_map_position(cell)
		curve.clear_points()
		emit_signal("walk_finished")
		move_speed = 600.0 # reset unit speed
	
	# Makes the unit move faster when they have been moving for some time.
	else:
		if move_speed <= 750.0:
			move_speed += 10.0
		else:
			move_speed += 150.0

func hurt_anim():
	_anim.play("hurt")

## Starts walking along the `path`.
## `path` is an array of grid coordinates that the function converts to map coordinates.
func walk_along(path: PackedVector2Array) -> void:
	if path.is_empty():
		return

	curve.add_point(Vector2.ZERO)
	for point in path:
		curve.add_point(grid.calculate_map_position(point) - position)
	cell = path[-1]
	_is_walking = true
