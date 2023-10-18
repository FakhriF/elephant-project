extends Button

#func _ready():
	# Set the text of the button when the scene is loaded
	$SelectProfile/ProfileButtontext.text = GameSystem.profile
