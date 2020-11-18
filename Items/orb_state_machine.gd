extends "res://Utils/state_machine.gd"

onready var animation_player = parent.get_node("AnimationPlayer")

func _ready():
	add_state("idle")
	add_state("move")
	add_state("stop")
	call_deferred('set_state', states.idle)

func _state_logic(_delta):
	parent.calculate_distance_to_target()
	match state:
		states.stop:
			parent.stop()
		states.move:
			parent.move()
		states.idle:
			pass

func _get_transition(_delta):
	if parent.distance_to_target.length_squared() > parent.STOP_DISTANCE.length_squared():
		return states.move
	elif abs(parent.global_position.distance_to(parent.idle_position)) < 2:
		return states.idle
	elif state == states.move:
		return states.stop

	return null
	
func _enter_state(new_state, _old_state):
	if new_state == states.idle:
		animation_player.play("Hover2")
	else:
		animation_player.stop(false)
