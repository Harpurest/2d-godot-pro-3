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
	STAGGER,
	DIE,
	DEATH
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
	STAGGER,
	DIE,
	DEATH
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
		[States.IDLE, Events.DIE]: States.DIE,
		
		[States.ATTACK, Events.IDLE]: States.IDLE,
		
		[States.STAGGER, Events.IDLE]: States.IDLE,
		[States.STAGGER, Events.STAGGER]: States.STAGGER,
		[States.STAGGER, Events.DIE]: States.DIE,

		[States.DIE, Events.DEATH]: States.DEATH,
	}

func _ready() -> void:
	$StateLabel.setup(self)
	$Health.connect("health_changed", self, "_on_Health_health_changed")
	$Tween.connect("tween_completed", self, "_on_Tween_tween_completed")
	$AnimationPlayer.connect("animation_finished", self, "_on_AnimationPlayer_animation_finished")
	$Hitbox.setup(self)
	$VisibilityNotifier2D.connect("screen_entered", self, "_on_screen_entered")
	$VisibilityNotifier2D.connect("screen_exited", self, "_on_screen_exited")
	visible = false

func _on_screen_entered():
	visible = true

func _on_screen_exited():
	visible = false

func change_state(event):
	var transition = [state, event]
	if not transition in _transitions:
		return
	
	match state:
		States.STAGGER:
			$Pivot/Body.modulate = Color('#ffffff')
		States.DIE:
			queue_free()
	
	state = _transitions[transition]

	enter_state()
	emit_signal("state_changed", state)

func enter_state():
	match state:
		States.IDLE:
			$AnimationPlayer.play("BASE")
			# continue will fallthrough the next check
			continue
		States.STAGGER:
			$AnimationPlayer.play("stagger")
			$Tween.interpolate_property(
				self,
				"position",
				position,
				position + (knockback_force * knockback_direction),
				KNOCKBACK_DURATION,
				Tween.TRANS_QUART,
				Tween.EASE_OUT
			)
			$Tween.start()
		States.DIE:
			$CollisionShape2D.set_deferred("disabled", true)
			$AnimationPlayer.play("die")


func _on_Health_health_changed(new_health):
	if new_health == 0:
		change_state(Events.DIE)
	else:
		change_state(Events.STAGGER)

func take_damage(source, amount):
	if self.is_a_parent_of(source):
		return
	knockback_direction = (global_position - source.global_position).normalized()
	$Health.take_damage(amount)

func _on_Tween_tween_completed(object, key):
	if key == ":position":
		change_state(Events.IDLE)

func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == 'die':
		change_state(Events.DEATH)
