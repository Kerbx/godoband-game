extends Node3D

@export var commands : Array[TerminalCommand]

@export_group("Nodes")
@export var keyboard_input : UnhandledKeyboardInput
@export var input_label : Label
@export var output_log : RichTextLabel
@export var camera_tweener : CameraTweener
@export var state_machine : StateMachine

@onready var terminal_screen: MeshInstance3D = $model/terminal_screen
@onready var sub_viewport: SubViewport = $SubViewport


# --- COMMAND SYSTEM ---
var command_map : Dictionary = {}
var session : TerminalSession = TerminalSession.new()

# --- TEXT / CARET ---
var input_text : String = ""
var text_anim : String = ""
var caret_visible : bool = true

# --- TERMINAL MODE ---
enum Mode { AUTH, NORMAL }
var current_mode : Mode = Mode.AUTH
var text_pre : String = "Login: "

# -------------------------------------------------
## Initializes the terminal: validates required nodes, sets up input,
## viewport, caret blinking, registers commands, and prints the welcome message.
func _ready() -> void:
	assert(input_label != null, "No input Label !")
	assert(keyboard_input != null, "No Input Thing !")
	assert(output_log != null, "No Log Rich Text Label !")

	_init_input()
	_init_viewport()
	_start_caret()
	_register_commands()
	_print("Terminal started.")
	_print("Type 'help' for available commands.")
	_update_input_label()

# -------------------------------------------------
# INPUT
# -------------------------------------------------
## Connects input signals from [UnhandledKeyboardInput]:
## character input appends to the current input buffer,
## erase removes the last character, and submit triggers command handling.
func _init_input() -> void:
	keyboard_input.input_key.connect(func (_char):
		input_text += _char
		_update_input_label()
	)

	keyboard_input.input_erase.connect(func ():
		if input_text.length() > 0:
			input_text = input_text.substr(0, input_text.length() - 1)
			_update_input_label()
	)

	keyboard_input.input_submit.connect(_handle_submit)

# -------------------------------------------------
# VIEWPORT
# -------------------------------------------------
## Binds the [SubViewport] texture to the terminal screen mesh material
## and sets the shading mode to unshaded for clean UI rendering.
func _init_viewport() -> void:
	var mat := terminal_screen.mesh.surface_get_material(0)
	mat.albedo_texture = sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

# -------------------------------------------------
# CARET
# -------------------------------------------------
## Starts a repeating timer that toggles caret visibility every 0.5 seconds,
## producing a blinking cursor effect in the input label.
func _start_caret() -> void:
	var timer := Timer.new()
	timer.wait_time = 0.5
	timer.autostart = true
	timer.timeout.connect(func():
		caret_visible = !caret_visible
		text_anim = "|" if caret_visible else ""
		_update_input_label()
	)
	add_child(timer)

# -------------------------------------------------
# COMMAND REGISTRATION
# -------------------------------------------------
## Populates [member command_map] by indexing all exported [TerminalCommand]
## resources by their [member TerminalCommand.command_name].
func _register_commands():
	for cmd in commands:
		command_map[cmd.command_name] = cmd

# -------------------------------------------------
# COMMAND HANDLER
# -------------------------------------------------
## Called when the user submits input. Prints the entered text to the log,
## clears the input buffer, and routes to auth or command handling
## depending on the current terminal mode.
func _handle_submit() -> void:
	var text := input_text.strip_edges()
	_print(text_pre + text)
	input_text = ""
	_update_input_label()

	if text.is_empty():
		return

	if current_mode == Mode.AUTH:
		_handle_auth(text)
	else:
		_handle_command(text)

# -------------------------------------------------
# AUTH MODE
# -------------------------------------------------
## Handles authentication input. Assigns the entered string as the session username,
## grants USER-level access, and switches the terminal to NORMAL mode.
func _handle_auth(input : String) -> void:
	if input.is_empty():
		_print("Enter username.")
		return

	session.user = input
	session.access_level = TerminalSession.AccessLevel.USER
	current_mode = Mode.NORMAL
	text_pre = "> "
	_print("Welcome, %s." % session.user)

# -------------------------------------------------
# NORMAL COMMAND MODE
# -------------------------------------------------
## Parses and executes a command string. Splits input into command name and arguments,
## looks up the command in [member command_map], checks the session access level,
## and calls [method TerminalCommand.execute] if all checks pass.
func _handle_command(input : String) -> void:
	var parts := input.split(" ")
	var command_name := parts[0]
	parts.remove_at(0)

	if not command_map.has(command_name):
		_print("Unknown command.")
		return

	var cmd : TerminalCommand = command_map[command_name]

	if session.access_level < cmd.required_access_level:
		_print("Access denied.")
		return

	cmd.execute(self, session, parts)

# -------------------------------------------------
# UTILS
# -------------------------------------------------
## Appends a message to the log [RichTextLabel] and scrolls to the last line.
func _print(msg : String) -> void:
	output_log.append_text(msg + "\n")
	output_log.scroll_to_line(output_log.get_line_count())

## Clears all content from the log [RichTextLabel].
func clear_log() -> void:
	output_log.clear()

## Updates the input [Label] to reflect the current prefix, input buffer,
## and caret animation character.
func _update_input_label() -> void:
	input_label.text = text_pre + input_text + text_anim

## Resets the session to guest state, switches the terminal back to AUTH mode,
## and prints a logout confirmation message.
func logout() -> void:
	session.user = ""
	session.access_level = TerminalSession.AccessLevel.GUEST
	current_mode = Mode.AUTH
	text_pre = "Login: "
	_print("Logged out.")
