extends Node3D

@export var input_thing : UnhandledKeyboardInput
@export var input_label : Label
@export var log_rich_text_label : RichTextLabel 

@onready var terminal_screen: MeshInstance3D = $terminal/terminal_screen
@onready var sub_viewport: SubViewport = $SubViewport

var text_pre : String = "Login: "
var text : String = ""
var text_anim : String = ""

func _ready() -> void:
	assert(input_label != null, "No input Label !")
	assert(input_thing != null, "No Input Thing !")
	assert(log_rich_text_label != null, "No Log Rich Text Label !")
	
	_init_input()
	_init_viewport()
	_init_caret_anim()
	
	_update_label()

func _init_input() -> void:
	input_thing.input_key.connect(func (_char):
		text += _char
		_update_label()
		)
	input_thing.input_erase.connect(func ():
		text = text.erase(max(text.length() - 1, 0))
		_update_label()
		)
	input_thing.input_submit.connect(_command_handler)

func _init_viewport() -> void:
	var mat := terminal_screen.mesh.surface_get_material(0)
	mat.albedo_texture = sub_viewport.get_texture()

func _init_caret_anim() -> void:
	while true:
		text_anim = "|"
		_update_label()
		await get_tree().create_timer(0.5, false).timeout
		text_anim = ""
		_update_label()
		await get_tree().create_timer(0.5, false).timeout

func _command_handler() -> void:
	match text:
		'clear':
			log_rich_text_label.clear()
		'boby':
			log_rich_text_label.clear()
			log_rich_text_label.append_text("Welcome back boby!")
		'fastfetch':
			log_rich_text_label.append_text("""
        ____              
       / __ \\____  _____ 
      / /_/ / __ \\/ ___/
     / ____/ /_/ (__  ) 
    /_/    \\____/____/  

OS: MS-DOS 6.22
Host: Generic AT-Compatible
Kernel: DOS 6.22
Uptime: 2 mins
Packages: N/A
Shell: COMMAND.COM
Resolution: 640x480
Terminal: VGA Text Mode
CPU: Intel 80486DX (1) @ 66 MHz
GPU: S3 Trio64 (1 MB)
Memory: 8 MB / 16 MB

Disk (/): 340 MB
Sound: Sound Blaster 16
BIOS: Award Modular BIOS v4.51PG
""")
	text_pre = ""
	text = ""
	
	_update_label()

func _update_label() -> void:
	input_label.text = text_pre + text + text_anim
