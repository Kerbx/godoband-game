extends Node
class_name UnhandledKeyboardInput

@export var disabled : bool = false :
	set(value):
		disabled = value
		set_process_unhandled_key_input(!value)

signal input_key(_char : String)
signal input_erase
signal input_submit
signal input_exit

func _ready() -> void:
	set_process_unhandled_key_input(!disabled)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.unicode > 0:
			input_key.emit(char(event.unicode))
		else:
			match event.keycode:
				KEY_BACKSPACE:
					input_erase.emit()
				KEY_ENTER:
					input_submit.emit()
				KEY_ESCAPE:
					input_exit.emit()
