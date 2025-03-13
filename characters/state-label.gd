extends Label

const Character = preload("res://characters/character.gd")

var _state_text = {
	Character.States.IDLE: "idle",
	Character.States.WALK: "walk",
	Character.States.RUN: "run",
	Character.States.BUMP: "bump",
	Character.States.JUMP: "jump",
	Character.States.FALL: "fall",
	Character.States.RESPAWN: "respawn",
	Character.States.ATTACK: "attack",
	Character.States.STAGGER: "stagger",
}

func setup(character):
	character.connect("state_changed", self, "_on_Character_state_changed")

func _on_Character_state_changed(state):
	text = _state_text[state]
