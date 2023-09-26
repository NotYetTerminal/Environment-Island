extends Spatial

func _process(_delta):
	if Input.is_action_pressed("left"):
		rotate_y(-0.05)
	if Input.is_action_pressed("right"):
		rotate_y(0.05)
