class Player:
	var charName
	var description
	var appearance
	var health
	var energy
	var movement
	var player

func _init(charName, description, appearance, health, energy, movement, player):
	self.charName = charName
	self.description = description
	self.appearance = appearance
	self.health = health
	self.energy = energy
	self.movement = movement
	self.player = player

func useSkill():
	pass
