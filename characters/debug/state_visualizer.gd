extends Label

const Monster = preload("res://monsters/monster.gd")

var state_str := {
	Monster.STATES.IDLE: 'Idle',
	Monster.STATES.ROAM: 'Roam',
	Monster.STATES.RETURN: 'Return',
	Monster.STATES.SPOT: 'Spot',
	Monster.STATES.FOLLOW: 'Follow',
	Monster.STATES.STAGGER: 'Stagger',
	Monster.STATES.ATTACK: 'Attack',
	Monster.STATES.ATTACK_COOLDOWN: 'Attack Cooldown',
	Monster.STATES.DIE: 'die',
	Monster.STATES.DEAD: 'dead'
}

func _physics_process(delta):
	text = state_str[get_parent().state]
