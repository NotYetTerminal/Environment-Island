extends Spatial

signal clicked

export var type = ""

var dead : bool = false


func _ready():
	if type == "Windmill":
		var direction = (randi() % 2 - 0.5) * 2
		$AnimationPlayer.get_animation("BladesAction").set_loop(true)
		$AnimationPlayer.play("BladesAction", -1, direction)


func delete(power_type_active: int, use_timer: bool) -> void:
	if use_timer:
		dead = true
		yield(get_tree().create_timer(randi() % 10), "timeout")
		$Destruction.destroy()
	if not dead:
		$Destruction.destroy()


func _on_StaticBody_input_event(_camera, event, _position, _normal, _shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			emit_signal("clicked", self, translation)
