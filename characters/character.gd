extends KinematicBody2D

signal state_changed(state)
signal direction_changed(direction)

export(String) var weapon_path = ""

var state = 0
var _transitions = {}
var weapon = null

func _ready() -> void:
	$StateLabel.setup(self)

func change_state(event):
	var transition = [state, event]
	if not transition in _transitions:
		return
	
	state = _transitions[transition]

	enter_state()
	emit_signal("state_changed", state)

func enter_state():
	pass
