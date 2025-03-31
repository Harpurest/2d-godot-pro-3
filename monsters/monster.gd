extends KinematicBody2D

enum STATES { 
	IDLE,
	ROAM,
	RETURN,
	SPOT,
	FOLLOW,
	STAGGER,
	ATTACK,
	ATTACK_COOLDOWN,
	DIE,
	DEAD
}
var state = null

var has_target := false
var target_position := Vector2()
var target


func _ready():
	_change_state(STATES.IDLE)

func set_target(player):
	target = player
	target_position = target.global_position
	print(target_position)

func _change_state(new_state):
	state = new_state

