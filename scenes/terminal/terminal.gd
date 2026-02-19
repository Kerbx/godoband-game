extends Node3D

# --- INPUT / UI ---
@export var input_thing : UnhandledKeyboardInput
@export var input_label : Label
@export var log_rich_text_label : RichTextLabel

@onready var terminal_screen: MeshInstance3D = $terminal/terminal_screen
@onready var sub_viewport: SubViewport = $SubViewport

@export var commands : Array[TerminalCommand]

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
func _ready() -> void:
	assert(input_label != null, "No input Label !")
	assert(input_thing != null, "No Input Thing !")
	assert(log_rich_text_label != null, "No Log Rich Text Label !")

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
func _init_input() -> void:
	input_thing.input_key.connect(func (_char):
		input_text += _char
		_update_input_label()
	)

	input_thing.input_erase.connect(func ():
		if input_text.length() > 0:
			input_text = input_text.substr(0, input_text.length() - 1)
			_update_input_label()
	)

	input_thing.input_submit.connect(_handle_submit)

# -------------------------------------------------
# VIEWPORT
# -------------------------------------------------
func _init_viewport() -> void:
	var mat := terminal_screen.mesh.surface_get_material(0)
	mat.albedo_texture = sub_viewport.get_texture()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED

# -------------------------------------------------
# CARET
# -------------------------------------------------
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
func _register_commands():
	for cmd in commands:
		command_map[cmd.command_name] = cmd

# -------------------------------------------------
# COMMAND HANDLER
# -------------------------------------------------
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
func _print(msg : String) -> void:
	log_rich_text_label.append_text(msg + "\n")
	log_rich_text_label.scroll_to_line(log_rich_text_label.get_line_count())

func clear_log() -> void:
	log_rich_text_label.clear()

func _update_input_label() -> void:
	input_label.text = text_pre + input_text + text_anim

func logout() -> void:
	session.user = ""
	session.access_level = TerminalSession.AccessLevel.GUEST
	current_mode = Mode.AUTH
	text_pre = "Login: "
	_print("Logged out.")
