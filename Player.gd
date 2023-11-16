extends CharacterBody2D

signal change_speed

@export var speed = 100 # How fast the player will move (pixels/sec).
@export var gravity = 980
@export var jump_strength = -300
var screen_size # Size of the game window.
var on_ground = false
var jump_from_dp = false
var platform_velocity = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if Input.is_action_just_pressed('speed_change'):
		change_speed.emit()
	on_ground = is_on_floor()
	if not on_ground:
		$AnimatedSprite2D.animation = "jump"
	# vertical movement velocity (down)
	velocity.y += gravity * delta
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
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_h = false
		if horizontal_input < 0:
			$AnimatedSprite2D.flip_h = true
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	# horizontal velocity which moves player left or right based on input
	velocity.x = horizontal_input * speed

