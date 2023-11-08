extends Resource
class_name TurnManager

enum {ALLY_TURN, ENEMY_TURN}

var turn := ALLY_TURN: set = set_turn
var turnCounter = 1;
var currentTurn;

signal ally_turn_started()
signal ally_turn_ended()
signal enemy_turn_started()

func set_turn(value : int) -> void:
	turn = value
	match turn:
		ALLY_TURN:
			currentTurn = "Ally Turn"
			emit_signal("ally_turn_started")
		ENEMY_TURN:
			currentTurn = "Enemy Turn"
			emit_signal("ally_turn_ended")
			emit_signal("enemy_turn_started")

func start() -> void:
	self.turn = ALLY_TURN

func advance_turn() -> void:
	self.turn = int(self.turn+1)&1
	self.turnCounter += 1
