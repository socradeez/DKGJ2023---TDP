extends CharacterBody2D

signal change_speed

@export var speed = 250 # How fast the player will move (pixels/sec).
@export var gravity = 980
@export var jump_strength = -500
var screen_size # Size of the game window.
var on_ground = false
var jump_from_dp = false
var platform_velocity = 0
var wall_slide_speed_max = 100
var wall_jump_strength = Vector2(150, -300) # X for away from the wall, Y for upward
var can_wall_jump = false
var wall_dir = 0 # -1 for left, 1 for right

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += gravity * delta
	if Input.is_action_just_pressed('speed_change'):
		change_speed.emit()
	on_ground = is_on_floor()
	print(on_ground)
	var is_on_wall = is_on_wall()
	if not on_ground:
		$AnimatedSprite2D.animation = "Jump"
		
	if is_on_wall and velocity.y > 0:
		# Wall sliding
		$AnimatedSprite2D.animation = "Jump"
		velocity.y = min(velocity.y, wall_slide_speed_max)
		can_wall_jump = true
		wall_dir = get_wall_direction()
	else:
		can_wall_jump = false

	if can_wall_jump and Input.is_action_just_pressed("jump"):
		perform_wall_jump()
	# vertical movement velocity (down)

	# horizontal movement processing (left, right)
	
	if on_ground:
		horizontal_movement()
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_strength
	# Otherwise, retain horizontal velocity
		
	#applies movement
	move_and_slide()

func horizontal_movement():
	# if keys are pressed it will return 1 for ui_right, -1 for ui_left, and 0 for neither
	var horizontal_input = Input.get_action_strength("move_right") -  Input.get_action_strength("move_left")
	if horizontal_input != 0:
		$AnimatedSprite2D.animation = "Run"
		$AnimatedSprite2D.flip_h = false
		if horizontal_input < 0:
			$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation = 'Idle'
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed
	
func get_wall_direction():
	var left_ray = $RayCast2D_Left
	var right_ray = $RayCast2D_Right

	if left_ray.is_colliding():
		return -1
	elif right_ray.is_colliding():
		return 1
	else:
		return 0  # Not on a wall

func perform_wall_jump():
	velocity.x = -wall_dir * wall_jump_strength.x
	velocity.y = wall_jump_strength.y

