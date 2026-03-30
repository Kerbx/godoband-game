extends CanvasLayer


@export var base_object: Node3D

@onready var pointer: TextureRect = $pointer
@onready var label: Label = $pointer/Label

var camera: FollowingCamera

var pointer_offset: Vector2
var viewport_size: Vector2
var viewport_center: Vector2
var max_pointer_pos: Vector2

var safe_margin: Vector2
func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	viewport_size = get_viewport().size
	viewport_center = viewport_size / 2
	pointer.pivot_offset.x = pointer.size.x / 2

	var diagonal_radius = pointer.size.length() / 2.0
	
	var padding = 2.0
	var total_margin = diagonal_radius + padding
	
	max_pointer_pos = viewport_center - Vector2(total_margin, total_margin)

var screen_pos: Vector2 = Vector2.ZERO
var is_on_screen: bool = true
func _process(delta: float) -> void:
	is_on_screen = camera.is_position_in_frustum(base_object.global_position)

	if is_on_screen:
		pointer.hide()
	else:
		pointer.show()
		var local_to_camera = camera.to_local(base_object.global_position)
		screen_pos = Vector2(local_to_camera.x, -local_to_camera.y)
		
		if screen_pos.abs().aspect() > max_pointer_pos.aspect(): 
			screen_pos *= max_pointer_pos.x / abs(screen_pos.x)
		else:
			screen_pos *= max_pointer_pos.y / abs(screen_pos.y)
		
		var angle = Vector2.UP.angle_to(screen_pos)
		pointer.rotation = angle
		
		pointer.set_global_position((viewport_center + screen_pos))
		
		label.text = str(snapped(camera.follow_object.global_position.distance_to(base_object.global_position), 0.1))
		
		
		
