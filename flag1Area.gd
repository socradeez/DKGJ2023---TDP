extends Area2D

signal player_collision
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_Area2D_body_entered(body):
	print(body)
	if body is CharacterBody2D: # or however you identify your player
		emit_signal("player_touched_flag")
