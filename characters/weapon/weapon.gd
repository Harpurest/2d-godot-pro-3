extends Area2D

signal attack_finished

var state = null
enum States {IDLE, ATTACK}

func _ready():
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	_change_state(States.IDLE)

func _physics_process(delta):
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.is_a_parent_of(self) or not body.has_node("Health"):
			continue
		body.queue_free()

func attack():
	_change_state(States.ATTACK)

func _change_state(new_state):
	match new_state:
		States.IDLE:
			set_physics_process(false)
			$AnimationPlayer.play("idle")
		States.ATTACK:
			set_physics_process(true)
			$AnimationPlayer.play("attack_straight")
	state = new_state

func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == "idle" or animation_name == "RESET":
		return

	_change_state(States.IDLE)
	emit_signal("attack_finished")
