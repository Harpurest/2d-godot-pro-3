extends Area2D

signal attack_finished
signal attack_info(isBehind, time)

var state = null

enum States {IDLE, ATTACK}
enum InputStates {IDLE, LISTENING, REGISTERED}

var current_input_state = InputStates.IDLE
var ready_for_next_attack := false

const MAX_COMBO_COUNT = 3;
var combo_count = 0;

var combo = [
	{
		'damage': 1,
		'animation': 'attack_fast'
	},
	{
		'damage': 1,
		'animation': 'attack_straight'
	},
	{
		'damage': 1,
		'animation': 'attack_medium'
	},
]

var attack_current = {}

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

func _physics_process(delta):
	if current_input_state == InputStates.REGISTERED and ready_for_next_attack:
		attack()

func _input(event):
	if state != States.ATTACK:
		return
	if current_input_state != InputStates.LISTENING:
		return
	if event.is_action_pressed("attack"):
		current_input_state = InputStates.REGISTERED

func set_input_state_listening():
	current_input_state = InputStates.LISTENING

func set_ready_for_next_attack():
	ready_for_next_attack = true

func _on_body_entered(body):
	var body_id = body.get_rid().get_id()
	if hit_bodies.has(body_id):
		return
	# hit_bodies[body_id] = true
	
	hit_bodies.append(body_id)
	body.take_damage(self, attack_current['damage'])

func attack():
	combo_count += 1;
	_change_state(States.ATTACK)

func _change_state(new_state):
	match state:
		States.ATTACK:
			hit_bodies.clear()
			current_input_state = InputStates.IDLE
			ready_for_next_attack = false
	
	match new_state:
		States.IDLE:
			combo_count = 0;
			monitoring = false
			$AnimationPlayer.play("idle")
		States.ATTACK:
			attack_current = combo[combo_count - 1]
			monitoring = true
			var animation_length = $AnimationPlayer.get_animation(attack_current['animation']).length
			emit_signal("attack_info", true, animation_length)
			$AnimationPlayer.play(attack_current['animation'])
	state = new_state

func _on_AnimationPlayer_animation_finished(animation_name):
	if animation_name == "idle" or animation_name == "RESET":
		return

	if combo_count < MAX_COMBO_COUNT and current_input_state == InputStates.REGISTERED:
		attack()
	else:
		_change_state(States.IDLE)
		emit_signal("attack_finished")

func publish_attack_info(isBehind: bool, time: float):
	emit_signal("attack_info", isBehind, time)
