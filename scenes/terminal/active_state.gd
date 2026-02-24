extends BaseTerminalState

var current_camera : Camera3D

func enter():
	current_camera = get_viewport().get_camera_3d()
	
	INPUT_THING.disabled = false
	
	if is_instance_valid(CAMERA_TWEENER):
		CAMERA_TWEENER.play(false, current_camera)
	
	EventBus.player_state_ui.emit(true)

func phyisic_update(_delta):
	if Input.is_action_just_pressed("escape"):
		state_machine.change_state("idle_state")

func exit():
	if is_instance_valid(CAMERA_TWEENER):
		await CAMERA_TWEENER.play(true, current_camera)
	EventBus.player_state_ui.emit(false)
