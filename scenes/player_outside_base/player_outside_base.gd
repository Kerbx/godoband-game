extends CharacterBody3D
class_name PlayerOutsideBase

signal interact_mode_enter(asteroid: Asteroid)

@export var speed = 5.0
@export var lerp_speed = 0.7
@export var model: Node3D


var direction: Vector3 = Vector3.ZERO

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

var rotation_dir:float = 0
func _physics_process(delta: float) -> void:
	rotation_dir = lerp(rotation_dir, Input.get_axis('move_left', 'move_right'), delta*lerp_speed*2)
	var input_dir := Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	direction = lerp(direction, (transform.basis * Vector3(0, 0, input_dir)).normalized(), delta * lerp_speed)
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	rotation.y = lerp_angle(rotation.y, deg_to_rad(rotation_degrees.y + -rotation_dir), lerp_speed*200*delta)
	
	move_and_slide()


#func _on_interact_mode_enter(asteroid: Asteroid) -> void:
	#cameras['up'].current = false
	#cameras['back'].current = true
