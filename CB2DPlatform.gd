extends CharacterBody2D


var path_to_follow: PathFollow2D

func _ready():
	path_to_follow = $".."

func _process(delta):

	# Update the global position of the platform to match the PathFollow2D position
	global_position = path_to_follow.global_position
	
