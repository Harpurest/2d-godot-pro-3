extends Position2D

func setup(character):
	# $"..".connect("direction_changed", self, "_on_Character_direction_changed")
	character.connect("direction_changed", self, "_on_Character_direction_changed")

func _on_Character_direction_changed(direction):
	rotation = direction.angle()
