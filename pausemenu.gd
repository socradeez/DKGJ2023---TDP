extends MenuBar

var pauseflag = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("pause") and not pauseflag:
		get_tree().paused = false
		visible = false
	pauseflag = false
