extends CharacterBody2D

signal change_speed_blue
signal change_speed_red
@export var max_speed = 500 # Max speed
@export var acceleration_rate = 15 # Acceleration rate
@export var deceleration_rate = 9 # Deceleration rate
@export var gravity = 2200
@export var jump_strength = -1024
@export var coyote_time = 0.05
@export var jump_buffer_time = 0.075
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var jump_buffered = false
var current_speed = 0 # Current horizontal speed
var screen_size # Size of the game window.
var on_ground = false
var jump_from_dp = false
var platform_velocity = 0
var wall_slide_speed_max = 275
var wall_jump_strength = Vector2(600, -1024) # X for away from the wall, Y for upward
var can_wall_jump = false
var wall_dir = 0 # -1 for left, 1 for right
enum MovementState {IDLE, RUNNING, SLIDING}
var movement_state = MovementState.IDLE
var previous_horizontal_input = 0
var start_position
var wall_jump_delay = 0.2
var wall_jump_timer = 0.0
var checkpoint2 = false
var has_jumped = false
var prev_floor_velocity = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	start_position = position  # Store the character's starting position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var jumped = false
	has_jumped = false  # Reset the flag at the beginning of each frame
	if position.x > 13600 and checkpoint2 == false:
		start_position = Vector2(13600, -97)
		checkpoint2 = true
	velocity.y += gravity * delta
	if Input.is_action_just_pressed("reset_character"):
		position = start_position
	if Input.is_action_just_pressed('speed_change_blue'):
		change_speed_blue.emit()
	if Input.is_action_just_pressed('speed_change_red'):
		change_speed_red.emit()
	on_ground = is_on_floor()
	var on_wall = get_wall_direction()
	handle_coyote_time(delta)
	handle_jump_buffer(delta)

	# Modify jump animation segments
	if velocity.y < -425:
		$AnimatedSprite2D.animation = "takeoff"
	elif 0 > velocity.y and velocity.y > -425:
		$AnimatedSprite2D.animation = "jump_top"
	elif not on_ground and not is_on_wall():
		$AnimatedSprite2D.animation = "flying_down"
	elif not on_ground:
		wall_jump_timer += delta
		
	if on_wall and velocity.y > 0:
		# Wall sliding
		$AnimatedSprite2D.animation = "WallSlide"
		velocity.y = min(velocity.y, wall_slide_speed_max)
		wall_dir = get_wall_direction()
		if wall_dir != 0:
			can_wall_jump = true
	else:
		can_wall_jump = false
		wall_jump_timer = 0.0
	if can_wall_jump and (Input.is_action_just_pressed("jump") or jump_buffered):
		perform_wall_jump()
		jump_buffered = false
	# vertical movement velocity (down)

	# horizontal movement processing (left, right)
	
	if on_ground:
		
		if Input.is_action_just_pressed("jump"):
			jumped = true
			perform_jump()
		horizontal_movement(delta)
	# Otherwise, retain horizontal velocity
	else:
		$AnimatedSprite2D.play()
		
	#applies movement
	move_and_slide()

func horizontal_movement(delta):
	var horizontal_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var target_speed_x = max_speed * horizontal_input
	var speed_difference = target_speed_x - velocity.x
	var some_threshold = 400

	# State transition logic
	if horizontal_input == 0 and movement_state != MovementState.SLIDING:
		movement_state = MovementState.IDLE
	elif horizontal_input != 0:
		if (movement_state == MovementState.SLIDING and abs(velocity.x) > some_threshold):
			movement_state = MovementState.SLIDING
		else:
			movement_state = MovementState.RUNNING

	# Movement logic based on state
	match movement_state:
		MovementState.IDLE:
			velocity.x = lerp(velocity.x, 0.0, delta * deceleration_rate)
		MovementState.RUNNING:
			velocity.x = lerp(velocity.x, target_speed_x, delta * acceleration_rate)
		MovementState.SLIDING:
			velocity.x = lerp(velocity.x, sign(previous_horizontal_input) * some_threshold, delta * deceleration_rate)

	# Animation logic based on state
	match movement_state:
		MovementState.IDLE:
			$AnimatedSprite2D.animation = "Idle"
		MovementState.RUNNING:
			$AnimatedSprite2D.animation = "Run"
		MovementState.SLIDING:
			$AnimatedSprite2D.animation = "SlideTurn"

	# Flip sprite based on direction
	if horizontal_input != 0:
		$AnimatedSprite2D.flip_h = horizontal_input < 0

	# Ensure the animation is playing
	$AnimatedSprite2D.play()

	# Store the previous input for comparison in the next frame
	previous_horizontal_input = horizontal_input
	
	
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
	# Determine the direction to jump away from the wall
	var jump_direction = -get_wall_direction()
	if jump_direction == 0:
		jump_direction = -sign(velocity.x)  # Fallback if wall direction can't be determined

	# Apply wall jump strength
	velocity.x = jump_direction * wall_jump_strength.x
	velocity.y = wall_jump_strength.y
	var wall_velocity = get_wall_velocity(jump_direction)
	velocity += wall_velocity
	$AnimatedSprite2D.flip_h = jump_direction < 0
	previous_horizontal_input = -previous_horizontal_input
	
func get_wall_velocity(jump_direction):
	var wall = get_colliding_wall(jump_direction)
	if wall and wall is AnimatableBody2D:
		return wall.get_velocity()
	return Vector2.ZERO

func get_colliding_wall(jump_direction):
	# Return the colliding wall object. This depends on your game's setup.
	# For example, you might use a RayCast2D that points in the direction of the wall.
	if jump_direction == 1:
		return $RayCast2D_Left.get_collider()
	elif jump_direction == -1:
		return $RayCast2D_Right.get_collider()
		
func handle_coyote_time(delta):
	if on_ground:
		coyote_timer = 0
		prev_floor_velocity = get_floor_velocity()
	else:
		coyote_timer += delta

	if coyote_timer < coyote_time and jump_buffered and not has_jumped:
		perform_jump()
		has_jumped = true
		
func handle_jump_buffer(delta):
	if jump_buffered:
		jump_buffer_timer += delta
		if jump_buffer_timer >= jump_buffer_time:
			jump_buffered = false

	if Input.is_action_just_pressed("jump") and not has_jumped:
		if on_ground or coyote_timer < coyote_time:
			perform_jump()
			has_jumped = true
		else:
			jump_buffered = true
			jump_buffer_timer = 0
			
func perform_jump():
	if not has_jumped:
		velocity.y = jump_strength
		velocity += get_floor_velocity()
		jump_buffered = false  # Reset jump buffer
		has_jumped = true

func _on_area_2d_body_entered(body):
	position = Vector2(9000, -97)
	start_position = position
	
func get_floor_velocity():
	var floor = $RayCast2D_Down.get_collider()
	if floor is AnimatableBody2D:
		return floor.velocity
	else:
		return Vector2.ZERO
		
func _on_end_flag_area_body_entered(body):
	var endmessage = get_node('../Label4')
	endmessage.z_index = 4


func _on_area_2d_2_body_entered(body):
	var stmessage = get_node("../STLabel")
	stmessage.z_index = 4
