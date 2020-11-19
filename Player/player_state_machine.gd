extends "res://Utils/state_machine.gd"

enum JUMP_TYPE {
	JUMP,
	JUMP_ON_WALL,
	JUMP_FROM_WALL,
	JUMP_FROM_WALL_TOP
}

var jump_type = JUMP_TYPE.JUMP
var jump_count = 0
var jump_max_count = 2

func _ready():
	add_state("idle")
	add_state("running")
	add_state("jumping")
	add_state("falling")
	add_state("climbing")
	call_deferred('set_state', states.idle)


func _state_logic(delta):
	_handle_input(delta)
	if [states.idle, states.running, states.jumping, states.falling].has(state):
		parent.apply_gravity(delta)

func _get_transition(_delta):
	# Changing to jump state is dynamically handled
	match state:
		states.idle:
			if parent.velocity.x != 0:
				return states.running
		states.running:
			if !parent.is_on_floor() and parent.velocity.y > 0:
					return states.falling
			elif parent.is_on_floor() and parent.velocity.x == 0:
				return states.idle
			elif parent.is_at_wall():
				return states.climbing
		states.jumping:
			if parent.is_on_floor():
				if parent.velocity.x != 0:
					return states.running
				else:
					return states.idle
			elif parent.is_at_wall() and parent.wall_climb_cooldown.is_stopped():
				return states.climbing
			elif parent.velocity.y > 0:
				return states.falling
		states.falling:
			if parent.is_on_floor():
				if parent.velocity.x != 0:
					return states.running
				else:
					return states.idle
			elif parent.is_at_wall() and parent.wall_climb_cooldown.is_stopped():
				return states.climbing
		states.climbing:
			if parent.is_on_floor():
				return states.idle
	return null

func _enter_state(new_state, _old_state):
	parent.collision_shape.position.y = 0
	match new_state:
		states.idle:
			parent.animation_tree_playback.travel("Idle")
		states.running:
			parent.animation_tree_playback.travel("Run")
		states.jumping:
			match jump_type:
				JUMP_TYPE.JUMP:
					parent.animation_tree_playback.travel("Jump")
				JUMP_TYPE.JUMP_FROM_WALL:
					parent.animation_tree_playback.travel("Jump")
				JUMP_TYPE.JUMP_FROM_WALL_TOP:
					parent.animation_tree_playback.travel("Jump")
				JUMP_TYPE.JUMP_ON_WALL:
					parent.animation_tree_playback.travel("JumpOnWall")
		states.falling:
			parent.animation_tree_playback.travel("Fall")
		states.climbing:
			parent.animation_tree_playback.start("Climb")
			parent.animation_tree.set('parameters/Climb/TimeScale/scale', 0)

func _exit_state(old_state, _new_state):
	match old_state:
		states.climbing:
			parent.wall_climb_cooldown.start()

func _handle_input(delta):
	var	vertical_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var	horizontal_input = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if Input.is_action_just_pressed("jump"):
		_handle_jump(horizontal_input, vertical_input)

	if state == states.climbing:
		if !parent.is_at_wall():
			horizontal_input = clamp(horizontal_input, 0, 1)
		if(horizontal_input != 0):
			parent.animation_tree.set('parameters/Climb/TimeScale/scale', 1)
		else:
			parent.animation_tree.set('parameters/Climb/TimeScale/scale', 0)
		parent.climb_wall(horizontal_input, delta)

	if [states.falling, states.running, states.jumping, states.idle].has(state):
		parent.apply_movement(vertical_input, delta)

	if Input.is_action_just_pressed("shoot"):
		parent.attack()

func _handle_jump(horizontal_input, vertical_input):
	if state == states.climbing or parent.is_on_floor():
		jump_count = 0
	
	if(horizontal_input > 0):
		set_state(states.falling)
	elif jump_count < _get_jump_max():
		jump_type = JUMP_TYPE.JUMP
		if state == states.climbing:
			if parent.climb_raycast.get_collision_normal().x != vertical_input:
				if parent.is_at_wall():
					jump_type = JUMP_TYPE.JUMP_ON_WALL
				else:
					jump_type = JUMP_TYPE.JUMP_FROM_WALL_TOP
			else:
				jump_type = JUMP_TYPE.JUMP_FROM_WALL

		parent.jump()
		jump_count += 1
		set_state(states.jumping)

func _get_jump_max():
	if parent.is_at_wall():
		return 1
	else:
		return jump_max_count
