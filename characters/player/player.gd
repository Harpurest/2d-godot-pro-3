extends "res://characters/character.gd"

onready var base_pivot = $Pivot.position
onready var base_shadow = $Shadow.position

signal speed_changed(speed, max_speed)

signal postion_changed
signal died

const MoveGroundStrategy = preload("res://characters/player/move-ground-strategy.gd")
const MoveAirStrategy = preload("res://characters/player/move-air-strategy.gd")

const SPEED = {
	States.WALK: 450,
	States.RUN: 700
}
const FALL_DURATION = 0.4
const BUMP_DISTANCE = 50
const JUMP_DURATION = {
	States.BUMP: 0.2,
	States.JUMP: 0.6
}
const JUMP_HEIGHT = {
	States.IDLE: 50,
	States.WALK: 50,
	States.RUN: 80
}

const MOVE_STRATEGY = {
	States.WALK: MoveGroundStrategy,
	States.RUN: MoveGroundStrategy,
	States.JUMP: MoveAirStrategy,
}

var _speed := 0.0 setget _set_speed, _get_speed
var _max_speed := 0.0
var _velocity := Vector2()

var _jump_duration = JUMP_DURATION[States.JUMP]
var _jump_height = JUMP_HEIGHT[States.IDLE]

var _collision_normal := Vector2()

var _pit_position := Vector2()
var _pit_distance := Vector2()

var _attack_duration = 0.3

var _last_input_direction := Vector2(1,0)

func _init():
	_transitions = {
		[States.IDLE, Events.WALK]: States.WALK,
		[States.IDLE, Events.RUN]: States.RUN,
		[States.IDLE, Events.JUMP]: States.JUMP,
		[States.IDLE, Events.FALL]: States.FALL,
		[States.IDLE, Events.ATTACK]: States.ATTACK,
		[States.IDLE, Events.STAGGER]: States.STAGGER,
		[States.IDLE, Events.DIE]: States.DIE,
		
		[States.WALK, Events.STOP]: States.IDLE,
		[States.WALK, Events.RUN]: States.RUN,
		[States.WALK, Events.JUMP]: States.JUMP,
		[States.WALK, Events.FALL]: States.FALL,
		[States.WALK, Events.ATTACK]: States.ATTACK,
		[States.WALK, Events.STAGGER]: States.STAGGER,
		
		[States.RUN, Events.STOP]: States.IDLE,
		[States.RUN, Events.WALK]: States.WALK,
		[States.RUN, Events.JUMP]: States.JUMP,
		[States.RUN, Events.BUMP]: States.BUMP,
		[States.RUN, Events.FALL]: States.FALL,
		[States.RUN, Events.ATTACK]: States.ATTACK,
		[States.RUN, Events.STAGGER]: States.STAGGER,
		
		[States.BUMP, Events.IDLE]: States.IDLE,
		
		[States.JUMP, Events.IDLE]: States.IDLE,
		
		[States.FALL, Events.RESPAWN]: States.RESPAWN,
		
		[States.RESPAWN, Events.IDLE]: States.IDLE,

		[States.ATTACK, Events.IDLE]: States.IDLE,

		[States.STAGGER, Events.IDLE]: States.IDLE,
		[States.STAGGER, Events.DIE]: States.DIE,

		[States.DIE, Events.DEATH]: States.DEATH,
	}

func _ready():
	$DirectionVisualizer.setup(self)

	"""
	if not weapon_path:
		return
	var weapon_node = load(weapon_path).instance()

	$WeaponPivot/WeaponSpawn.add_child(weapon_node)
	"""
	weapon = $WeaponPivot/WeaponSpawn.get_child(0)
	weapon.connect("attack_finished", self, "on_Weapon_attack_finished")
	weapon.connect("attack_info", self, "on_Weapon_attack_info")

	$WeaponPivot.setup(self)

func _physics_process(delta):
	var slide_count = get_slide_count()
	_collision_normal = get_slide_collision(slide_count - 1).normal if slide_count > 0\
		else _collision_normal
	
	var input = get_raw_input(state, slide_count)
	_last_input_direction = input.direction if input.direction != Vector2() else _last_input_direction
	emit_signal("direction_changed", _last_input_direction)
	var event = decode_raw_input(input)

	change_state(event)
	
	match state:
		States.WALK, States.RUN, States.JUMP:
			var params = MOVE_STRATEGY[state].go(input.direction, _speed, _max_speed,_velocity, delta)
			self._speed = params.speed
			self._velocity = params.velocity
			_move()
			
func _move():
	move_and_slide(self._velocity)
	"""
	var viewport_size = get_viewport().size
	for i in range(2):
		if position[i] < 0:
			position[i] = viewport_size[i]
		if position[i] > viewport_size[i]:
			position[i] = 0
	"""

func _animate_jump(progress):
	var pivot_height = _jump_height * pow(sin(progress * PI), 0.7)
	var shadow_scale = 1.0 - pivot_height / _jump_height * 0.5
	$Pivot.position.y = -pivot_height;
	$Shadow.scale = Vector2(shadow_scale, shadow_scale)
	
func _animate_attack(progress):
	var pivot_position = -20 * sin(1.5 * progress * PI)
	$Pivot.position = base_pivot + (pivot_position * _last_input_direction)
	$Shadow.position = base_shadow + (pivot_position * _last_input_direction)

func enter_state():
	match state:
		States.IDLE, States.JUMP, States.BUMP:
			$AnimationPlayer.play("BASE")
			# continue will fallthrough the next check
			continue

		States.IDLE:
			_velocity = Vector2()
			_max_speed = SPEED[States.WALK]
			_jump_height = JUMP_HEIGHT[state]
			self._speed = 0

		States.WALK, States.RUN:
			_max_speed = SPEED[state]
			self._speed = _max_speed
			_jump_height = JUMP_HEIGHT[state]
			$AnimationPlayer.playback_speed = _max_speed / SPEED[States.WALK]
			$AnimationPlayer.play("move")

		States.BUMP, States.JUMP:
			_jump_duration = JUMP_DURATION[state]
			if state == States.BUMP:
				$Tween.interpolate_property(
					self,
					"position",
					position,
					position + BUMP_DISTANCE * _collision_normal,
					_jump_duration,
					Tween.TRANS_LINEAR,
					Tween.EASE_IN)
			$Tween.interpolate_method(
				self,
				"_animate_jump",
				0,
				1,
				_jump_duration,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			$Tween.start()

		States.FALL:
			$Tween.interpolate_property(
				self,
				"scale",
				scale,
				Vector2(),
				FALL_DURATION / 2.0,
				Tween.TRANS_QUAD,
				Tween.EASE_IN)
			$Tween.start()

		States.RESPAWN:
			position = _pit_position + _last_input_direction.rotated(PI) * _pit_distance

			$Tween.interpolate_property(
				self,
				"scale",
				scale,
				Vector2(0.7, 0.7),
				FALL_DURATION / 2.0,
				Tween.TRANS_LINEAR,
				Tween.EASE_IN)
			$Tween.start()

		States.ATTACK:
			if not weapon:
				change_state(Events.IDLE)
				return
			weapon.attack()
			set_physics_process(false)

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
			# No more input when die
			# set_physics_process(false)
			set_process_input(false)
			$CollisionShape2D.set_deferred("disabled", true)
			$AnimationPlayer.play("die")

func get_raw_input(state, slide_count):
	return {
		direction = utils.get_input_direction(),
		is_running = Input.is_action_pressed("run"),
		is_jumping = Input.is_action_pressed("jump"),
		is_bumping = (state == States.RUN and slide_count > 0),
		is_attacking = Input.is_action_pressed("attack")
	}

func decode_raw_input(input):
	var event = Events.INVALID

	if input.direction == Vector2():
		event = Events.STOP
	elif input.is_running:
		event = Events.RUN
	else:
		event = Events.WALK
	
	if input.is_attacking:
		event = Events.ATTACK
	if input.is_jumping:
		event = Events.JUMP
	if input.is_bumping:
		event = Events.BUMP

	return event

func _set_speed(new_speed):
	if _speed == new_speed:
		return
	_speed = new_speed
	emit_signal("speed_changed", new_speed, SPEED[States.RUN])
	
func _get_speed():
	pass
	
func _on_Tween_tween_completed(object, key):
	if key == ":_animate_jump":
		change_state(Events.IDLE)
	if key == ":scale" and (scale <= Vector2(0.7, 0.7) * 1.05 and scale >= Vector2(0.7, 0.7) * 0.95):
		change_state(Events.IDLE)
	if key == ":scale" and scale.round() == Vector2():
		change_state(Events.RESPAWN)
	if key == ":position":
		change_state(Events.IDLE)

func _on_Pit_body_fell(body, pit_position, pit_distance):
	if body != self:
		return
	_pit_position = pit_position
	_pit_distance = pit_distance
	change_state(Events.FALL)

func on_Weapon_attack_finished():
	set_physics_process(true)
	
	# $Tween.stop(self, "_animate_attack")
	# $Tween.stop(self)
	# $Tween.remove_all()

	$Pivot.position = base_pivot
	$Shadow.position = base_shadow

	change_state(Events.IDLE)
	$AnimationPlayer.play("BASE")

func on_Weapon_attack_info(isBehind, time):
	$Tween.stop(self, "_animate_attack")
	$Tween.remove_all()
	$Pivot.position = base_pivot
	$Shadow.position = base_shadow

	_attack_duration = time - 0.01;
	$WeaponPivot.show_behind_parent = isBehind

	$Tween.interpolate_method(
		self,
		"_animate_attack",
		0,
		1,
		_attack_duration,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN
	)
	$Tween.start()
