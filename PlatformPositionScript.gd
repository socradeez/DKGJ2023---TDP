extends PathFollow2D

@export var max_speed = 1.0
@export var speed_multiplier = 2.0
var current_speed = 0.0
var direction = 1
var high_speed = false
var smoothing_factor = 0.03  # Adjust for more/less smoothing
var old_position = Vector2()
var velocity = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Set an initial speed to start moving
	current_speed = max_speed * direction
	old_position = global_position

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
		
	velocity = (global_position - old_position) / delta
	old_position = global_position

func _on_player_change_speed_blue():
	if high_speed:
		max_speed /= 2
		high_speed = false
		$AB2DPlatform/TileMap_powered.z_index = 0
	else:
		max_speed *= 2
		high_speed = true
		$AB2DPlatform/TileMap_powered.z_index = 4

	
func get_velocity():
	return velocity


func _on_player_change_speed_red():
	if high_speed:
		max_speed /= speed_multiplier
		high_speed = false
		$AB2DPlatform/TileMap_powered.z_index = 0
	else:
		max_speed *= speed_multiplier
		high_speed = true
		$AB2DPlatform/TileMap_powered.z_index = 4



