class_name BaseTerminalState
extends State

var CAMERA_TWEENER : CameraTweener
var INPUT_THING : UnhandledKeyboardInput

func _ready() -> void:
	CAMERA_TWEENER = owner.camera_placement
	INPUT_THING = owner.input_thing 
