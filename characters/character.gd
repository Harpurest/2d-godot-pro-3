extends KinematicBody2D

signal state_changed(state)
signal direction_changed(direction)

export(String) var weapon_path = ""

enum States {
	IDLE,
	WALK,
	RUN,
	BUMP,
	JUMP,
	FALL,
	RESPAWN,
	ATTACK,
	STAGGER
}

enum Events {
	INVALID=-1,
	STOP,
	IDLE,
	WALK,
	RUN,
	BUMP,
	JUMP,
	FALL,
	RESPAWN,
	ATTACK,
	STAGGER
}

var knockback_direction := Vector2()
export(float) var knockback_force := 10.0
const KNOCKBACK_DURATION := 0.4

var state = 0
var _transitions = {}
var weapon = null

func _init():
	_transitions = {
		[States.IDLE, Events.ATTACK]: States.ATTACK,
		[States.IDLE, Events.STAGGER]: States.STAGGER,
		[States.ATTACK, Events.IDLE]: States.IDLE,
	}

func _ready() -> void:
	$StateLabel.setup(self)
	$Health.connect("health_changed", self, "_on_Health_health_changed")

func change_state(event):
	var transition = [state, event]
	if not transition in _transitions:
		return
	
	state = _transitions[transition]

	enter_state()
	emit_signal("state_changed", state)

func enter_state():
	match state:
		States.IDLE:
			$AnimationPlayer.play("BASE")
			# continue will fallthrough the next check
			continue

func _on_Health_health_changed(new_health):
	change_state(Events.IDLE)
	if new_health == 0:
		queue_free()

func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	$Health.take_damage(amount)
