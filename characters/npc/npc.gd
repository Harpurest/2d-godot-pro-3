extends "res://characters/character.gd"

const STOP_THRESHOLD := 1e-2
const PATROL_DISTANCE := 200
const SPEED := 300

var _direction := Vector2(-1,0)
var _target_position := Vector2()

func _init() -> void:
	_transitions = {
		[States.IDLE, Events.WALK]: States.WALK,
		[States.WALK, Events.STOP]: States.IDLE
	}

func _ready() -> void:
	$CollisionShape2D.disabled = true
	$Timer.connect("timeout", self, "change_state", [Events.WALK])
	$Timer.wait_time = 0.5 + 1.5 * randf()
	$Timer.start()
	$VisibilityNotifier2D.connect("screen_entered", self, "_on_screen_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
	
func _physics_process(delta):
	match state:
		States.WALK:
			_walk()

func _walk() -> void:
	var velocity = SPEED * _direction
	move_and_slide(velocity);
	if (position - _target_position).length() < STOP_THRESHOLD:
		change_state(Events.STOP)

func enter_state():
	match state:
		States.IDLE:
			$Timer.start()
			$AnimationPlayer.play("BASE")
		States.WALK:
			_direction.x *= -1
			_target_position = position + (PATROL_DISTANCE * _direction)
			$AnimationPlayer.play("move")
