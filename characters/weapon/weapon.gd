extends Area2D

signal attack_finished
signal attack_info(isBehind, time)

var state = null
enum States {IDLE, ATTACK}

export var power = 1;

# var hit_bodies := {}
var hit_bodies := []

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	self.connect("body_entered", self, "_on_body_entered")
	_change_state(States.IDLE)

"""
func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.has_node("Health") and not body.is_a_parent_of(self):
			var body_id = body.get_rid().get_id()
			if hit_bodies.has(body_id):
				continue
			# hit_bodies[body_id] = true
			hit_bodies.append(body_id)
			body.get_node("Health").take_damage(1)
"""

func _on_body_entered(body):
	var body_id = body.get_rid().get_id()
	if hit_bodies.has(body_id):
		return
	# hit_bodies[body_id] = true
	hit_bodies.append(body_id)
	body.take_damage(self, power)

func attack():
	_change_state(States.ATTACK)

func _change_state(new_state):
	match state:
		States.ATTACK:
			hit_bodies.clear()
	
	match new_state:
		States.IDLE:
			monitoring = false
			$AnimationPlayer.play("idle")
		States.ATTACK:
			monitoring = true
			$AnimationPlayer.play("attack_straight")
	state = new_state

func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == "idle" or animation_name == "RESET":
		return

	_change_state(States.IDLE)
	emit_signal("attack_finished")

func publish_attack_info(isBehind: bool, time: float):
	emit_signal("attack_info", isBehind, time)
