class Character:
	var name
	var image
	var stats

func _init(name, image, stats):
	self.name = name
	self.image = image
	self.stats = stats

func get_name():
	return self.name

func get_image():
	return self.image

func get_stats():
	return self.stats
