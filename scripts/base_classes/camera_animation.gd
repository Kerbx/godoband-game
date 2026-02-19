extends Node

@export var trans_type : Tween.TransitionType = Tween.TRANS_SINE
@export var ease_type : Tween.EaseType = Tween.EASE_IN_OUT

@export var camera_fov : float = 75.0
@export var animation_duration : float = 1.0

var animated_camera: Camera3D
var original_camera: Camera3D

# TEST THING
#func _ready() -> void:
	#var c_camera : Camera3D = get_viewport().get_camera_3d()
	#await get_tree().create_timer(1).timeout
	#play(false, c_camera)
	#await get_tree().create_timer(10).timeout
	#play(true, c_camera)

func play(
	backwards: bool = false,
	player_camera: Camera3D = null
) -> void:
	var tween: Tween = create_tween()
	
	if not backwards:
		original_camera = player_camera
		
		animated_camera = Camera3D.new()
		add_child(animated_camera)
		
		animated_camera.global_transform = original_camera.global_transform
		animated_camera.fov = original_camera.fov
		animated_camera.make_current()
		
		tween.tween_property(
			animated_camera,
			"global_transform",
			self.global_transform,
			animation_duration
		).set_trans(trans_type).set_ease(ease_type)
		
		tween.parallel().tween_property(
			animated_camera,
			"fov",
			camera_fov,
			animation_duration
		).set_trans(trans_type).set_ease(ease_type)
		
	else:
		if animated_camera == null:
			return
		
		tween.tween_property(
			animated_camera,
			"global_transform",
			original_camera.global_transform,
			animation_duration
		).set_trans(trans_type).set_ease(ease_type)
		
		tween.parallel().tween_property(
			animated_camera,
			"fov",
			original_camera.fov,
			animation_duration
		).set_trans(trans_type).set_ease(ease_type)
		
		await tween.finished
		
		original_camera.make_current()
		animated_camera.queue_free()
		animated_camera = null
