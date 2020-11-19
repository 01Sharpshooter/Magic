extends KinematicBody2D

const Projectile = preload("res://Player/Attacks/homing_projectile.tscn")
const Orb = preload("res://Items/orb.tscn")
const GRAVITY = 650.0
const MAX_SPEED = 300
const CLIMBING_SPEED = 75
const ACCELERATION = 2000
const JUMP_HEIGHT = -400

onready var enemyDetection = $EnemyDetection
onready var animation_tree = $AnimationContainer/AnimationTree
onready var animation_tree_playback = animation_tree.get("parameters/playback")
onready var animation_container = $AnimationContainer
onready var climb_raycast = $AnimationContainer/ClimbRayCast
onready var collision_shape = $CollisionShape2D
onready var wall_climb_cooldown = $WallClimbCooldown

var magazine = []
var velocity = Vector2.ZERO

var orb

func _ready():
	create_projectiles(5)
	orb = Orb.instance()
	self.add_child(orb)
	orb.follow(self)
	animation_tree.active = true;
	
func apply_gravity(delta):
		velocity.y += GRAVITY * delta

func jump():
	velocity.y = JUMP_HEIGHT

func attack():
	var overlapping = ArrayUtils.filter(enemyDetection.get_overlapping_bodies(), funcref(self, "is_body_mob"))
	if overlapping:
		var targetIndex = randi() % overlapping.size()
		shoot(overlapping[targetIndex].global_position)
	else:
		shoot(global_position)

func apply_movement(input_vector, delta):
	velocity.x = move_toward(velocity.x, MAX_SPEED * input_vector, ACCELERATION * delta)
	if input_vector != 0:
		animation_container.scale.x = input_vector
	velocity = move_and_slide(velocity, Vector2.UP)
	
func climb_wall(climb_vector, _delta):
	velocity.y = climb_vector * CLIMBING_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)
	
func is_at_wall():
	return climb_raycast.is_colliding()

func is_body_mob(body: PhysicsBody2D) -> bool:
	return body.is_in_group("mobs")

func create_projectiles(number):
	for _i in range(0, number):
		var projectile = Projectile.instance()
		add_child(projectile)
		magazine.append(projectile)

func shoot(_target):
	var ammo = get_ready_ammo()
	if ammo:
		ammo.fire(_target, orb.global_position)

func get_ready_ammo():
	for ammo in magazine:
		if ammo.readyToUse:
			return ammo
