extends PathFollow2D

@export var max_speed = 1.0
@export var speed_multiplier = 2.0
var current_speed = 0.0
var direction = 1
var high_speed = false
var smoothing_factor = 0.015  # Adjust for more/less smoothing

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set an initial speed to start moving
	current_speed = max_speed * direction

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var target_speed = max_speed

	# Apply smoothing near the ends of the path
	if progress_ratio < smoothing_factor:
		target_speed *= progress_ratio / smoothing_factor + 0.1  # Ensure minimum speed
	elif progress_ratio > 1.0 - smoothing_factor:
		target_speed *= (1.0 - progress_ratio) / smoothing_factor + 0.1  # Ensure minimum speed

	# Update current_speed
	current_speed = target_speed * direction

	# Update progress_ratio
	progress_ratio += current_speed * delta

	# Check for path end and reverse direction if necessary
	if progress_ratio >= 1.0:
		progress_ratio = 1.0
		direction *= -1
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0
		direction *= -1

func _on_player_change_speed_blue():
	if high_speed:
		max_speed /= 2
		high_speed = false
	else:
		max_speed *= 2
		high_speed = true

	
func get_velocity():
	var old_pos = global_position
	var new_pos = $Path.curve.interpolate_baked(progress_ratio + current_speed * get_process_delta_time(), true)
	return (new_pos - old_pos) / get_process_delta_time()


func _on_player_change_speed_red():
	if high_speed:
		max_speed /= speed_multiplier
		high_speed = false
	else:
		max_speed *= speed_multiplier
		high_speed = true

