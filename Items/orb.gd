extends KinematicBody2D

const STOP_DISTANCE = Vector2(-70, -70)
const IDLE_DISTANCE = Vector2(-60, -60)

var target = null
var distance_to_target= Vector2.ZERO
var idle_position = Vector2.ZERO

func _ready():
	set_as_toplevel(true)

func follow(_target):
	target = _target
	global_position = target.global_position + Vector2(-60, -60)
	
func move():
	# warning-ignore:return_value_discarded
	move_and_slide(distance_to_target.normalized() * distance_to_target.length() * 2)
	
func stop():
	idle_position = target.global_position + Vector2(-(sign(distance_to_target.x) * 60), -60)
	# warning-ignore:return_value_discarded
	move_and_slide(global_position.direction_to(idle_position) * 50)	
	
func calculate_distance_to_target():
	distance_to_target = target.global_position - global_position
