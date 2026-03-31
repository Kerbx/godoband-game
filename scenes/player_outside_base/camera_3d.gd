extends Camera3D
class_name FollowingCamera

@export var follow_object: PlayerOutsideBase
@export var height: float = 10

var camera_tween: Tween
var offset: float = 0
var pinned: bool = false

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	global_position = follow_object.global_position + follow_object.basis.z * offset + Vector3(0,height,0)
	if pinned:
		look_at(follow_object.position)



@warning_ignore("unused_parameter")
func _on_player_outside_base_interact_mode_enter(asteroid: Asteroid) -> void:
	print('change camera position')
	camera_tween = get_tree().create_tween()
	
	camera_tween.parallel().tween_property(self, "height", 0.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	camera_tween.parallel().tween_property(self, "offset", 0.1, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	pinned = true
