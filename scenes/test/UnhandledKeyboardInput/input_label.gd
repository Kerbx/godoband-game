extends Label

@export var keyboard_input : UnhandledKeyboardInput

func _ready() -> void:
	keyboard_input.input_key.connect(func (_char):
		text += _char
		)
	keyboard_input.input_erase.connect(func ():
		text = text.erase(max(text.length() - 1, 0))
		)
