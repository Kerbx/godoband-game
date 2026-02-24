extends CharacterBody3D
class_name PlayerInBase


## Сигнал, отключающий движение робота
signal player_movement_disable
## Сигнал, включающий движение робота
signal player_movement_enable




@export_category("Specs:")
@export var speed_walk : float = 5.0
@export var speed_run : float = 8.5
@export var gravity : float = 9.8
@export var stop_movement_speed : float = 3
@export var start_movement_speed : float = 2
@export var tilt_multiplier = 0.1
@export var mouse_sensetivity : float = 0.065

@export_category("Nodes:")
@export var state_machine: StateMachine
@export var _interactor : Interactor
@export var camera : Camera3D
@export var head : Node3D
@export var mesh_body: Node3D
@export var wheel: Node3D

@export_category("Sounds")


var speed : float = 0.0
var direction : Vector3
var input_dir := Vector2.ZERO

var can_move : bool = true
var can_rotate : bool = true

var fov_base : float = 80
var fov_move : float = 7


func _input(event: InputEvent) -> void:
	# Вращение головы
	if event is InputEventMouseMotion and can_rotate:
		var mouse_vector = Vector2(event.relative.x, event.relative.y) * mouse_sensetivity
		
		camera.rotation_degrees.x += -mouse_vector.y
		head.rotation_degrees.y += -mouse_vector.x
		camera.rotation_degrees.x = clampf(camera.rotation_degrees.x, -90, 90)

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	player_movement_disable.connect(movement_disable)
	player_movement_enable.connect(movement_enable)

func movement_disable():
	can_move = false
	can_rotate = false
	
	if _interactor:
		_interactor.disabled = true

func movement_enable():
	can_move = true
	can_rotate = true
	
	if _interactor:
		_interactor.disabled = false



func _physics_process(delta: float) -> void:
	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not can_move:
		return
	
	# Движение
	if can_move:
		input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		direction = (head.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		# Поворот колеса
		if input_dir:
			wheel.rotation.y = lerp_angle(wheel.rotation.y, atan2(input_dir.x, input_dir.y), 0.05)
		
	else:
		input_dir = Vector2.ZERO
		direction = Vector3.ZERO
	
	# Замедление движения в воздухе
	if is_on_floor():
		velocity.x = lerp(velocity.x, direction.x * speed, start_movement_speed * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, start_movement_speed * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, stop_movement_speed * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, stop_movement_speed * delta)
	
	# Наклон головы
	if input_dir and is_on_floor():
		head.rotation.z = lerp(head.rotation.z, -input_dir.x * tilt_multiplier, 0.075)
		head.rotation.x = lerp(head.rotation.x, input_dir.y * tilt_multiplier, 0.075)
	else:
		head.rotation.z = lerp(head.rotation.z, 0.0, 0.1)
		head.rotation.x = lerp(head.rotation.x, 0.0, 0.1)
	
	# Изменение FOV во время движения
	var velocity_clamped = clamp(input_dir.length() * (velocity.length()/5), 0, 8)
	
	# Поворот тела
	mesh_body.rotation_degrees.y = lerp(mesh_body.rotation_degrees.y, head.rotation_degrees.y + 90, 0.1)
	
	wheel.rotation_degrees.z += (velocity.length() * delta * 35)
	#print(velocity.length()*delta)
	
	camera.fov = lerp(camera.fov, fov_base + fov_move * velocity_clamped, 0.025)
	move_and_slide()
	
