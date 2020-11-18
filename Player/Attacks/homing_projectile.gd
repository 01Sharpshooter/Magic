extends Area2D

onready var line = $Line2D
onready var timer = $Timer

const ACCELERATION = 4500
const MAX_SPEED = 2500
const STARTING_SPEED = 800
const LIFE_DURATION = 1.5

var velocity = Vector2.ZERO
var target = Vector2.ZERO

var toDestroy = false
var readyToUse = true

func _ready():
	line.set_as_toplevel(true)
	monitoring = false
	set_physics_process(false)

func fire(_target, _from_position):
	global_position = _from_position
	target = _target
	init()
	
	timer.start(LIFE_DURATION)
	
func init():
	toDestroy = false
	velocity = Vector2(rand_range(-0.75, 0.75), -0.5) * STARTING_SPEED
	readyToUse = false
	set_deferred("monitoring", true)
	set_physics_process(true)

func _physics_process(delta):
	if toDestroy and line.get_point_count() == 0:
		stop()
		return
	
	draw_trail()
	
	velocity = velocity.move_toward(global_position.direction_to(target) * MAX_SPEED, ACCELERATION * delta)
	rotation = velocity.angle()
	position += velocity * delta

func draw_trail():
	if line.get_point_count() > 10 or toDestroy:
		line.remove_point(0)
	else:
		line.add_point(global_position)

func stop():
	set_physics_process(false)
	set_deferred("monitoring", false)
	readyToUse = true
	

func _on_body_exited(_body):
	toDestroy = true

func _on_Timer_timeout():
	toDestroy = true
