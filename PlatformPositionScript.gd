extends PathFollow2D

@export var speed = 10.0
var high_speed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	progress_ratio += speed * delta
	
	# When reaching the end of the path, reverse direction
	if progress_ratio >= 1.0:
		progress_ratio = 1.0  # Clamp progress to the end
		speed = -speed  # Reverse speed

	# When reaching the start of the path, reverse direction again
	elif progress_ratio <= 0.0:
		progress_ratio = 0.0  # Clamp progress to the start
		speed = -speed  # Reset to initial speed
		
		
func _on_player_change_speed():
	if high_speed:
		speed /= 2
		high_speed = false
	else:
		speed *= 2
		high_speed = true
	
