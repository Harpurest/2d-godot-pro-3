extends Node

static func get_input_direction(event=Input) -> Vector2:
	return Vector2(
		float(event.is_action_pressed("move_right")) 
			- float(event.is_action_pressed("move_left")),
		float(event.is_action_pressed("move_down")) 
			- float(event.is_action_pressed("move_up"))
	).normalized()
