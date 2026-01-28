extends Label

@export var input_thing : UnhandledKeyboardInput

func _ready() -> void:
	input_thing.input_key.connect(func (_char):
		text += _char
		)
	input_thing.input_erase.connect(func ():
		text = text.erase(max(text.length() - 1, 0))
		)
