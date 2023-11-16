extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	var player = $Player
	var platforms = get_tree().get_nodes_in_group("RedPlatforms")
	
	for platform in platforms:
		player.connect("")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
