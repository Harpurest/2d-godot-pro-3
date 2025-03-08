static func go(direction, speed, max_speed, velocity, delta):
	return {
		velocity = direction * speed,
		speed = speed
	}
