extends Camera3D
class_name FollowingCamera

@export var follow_object: PlayerOutsideBase
@export var height: float = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position = Vector3(follow_object.global_position.x, follow_object.global_position.y + height, follow_object.global_position.z)
