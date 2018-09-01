extends KinematicBody2D

var direction = Vector2()

const UP	= Vector2(0, -1)
const DOWN	= Vector2(0, 1)
const RIGHT = Vector2(1, 0)
const LEFT	= Vector2(-1, 0)

var speed = 0
const MAX_SPEED = 200

func _ready():
	pass
#endfunc

func _physics_process(delta):
	var is_moving = Input.is_action_pressed("move_down") or Input.is_action_pressed("move_up") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_left")

	direction = Vector2()

	if is_moving:
		speed = MAX_SPEED
	else:
		speed = 0

	if Input.is_action_pressed("move_up"):
		direction += UP
	elif Input.is_action_pressed("move_down"):
		direction += DOWN

	if Input.is_action_pressed("move_right"):
		direction += RIGHT
	elif Input.is_action_pressed("move_left"):
		direction += LEFT

	var velocity = speed * direction * delta
	move_and_collide(velocity)
#endfunc