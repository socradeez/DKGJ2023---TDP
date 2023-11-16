extends RigidBody2D

@export var speed = 100
@export var left_distance = 100
@export var right_distance = 100
var minX = 0
var maxX = 0
var direction = 1
var center = Vector2(0, 0)
var is_moving = true


# Called when the node enters the scene tree for the first time.
func _ready():
	center = position
	minX = center.x - left_distance
	maxX = center.x + right_distance

func _physics_process(delta):
	var x = global_position.x
	if x < minX or x > maxX:
		direction *= -1
		
	linear_velocity.x = speed * direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_player_change_speed():
	if speed == 100:
		speed = 200
	elif speed == 200:
		speed = 100
