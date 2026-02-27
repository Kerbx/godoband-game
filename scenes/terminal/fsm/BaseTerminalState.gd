class_name BaseTerminalState
extends State

var CAMERA_TWEENER : CameraTweener
var KEYBOARD_INPUT : UnhandledKeyboardInput

func _ready() -> void:
	CAMERA_TWEENER = owner.camera_tweener
	KEYBOARD_INPUT = owner.keyboard_input 
