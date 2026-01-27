extends Node
class_name UISounds

@export var hover_sound : bool = true
@export var toggle_sound : bool = true
@export var pressed_sound : bool = true

@export var sound_hover : AudioStream 
@export var sound_toggled_on : AudioStream
@export var sound_toggled_off : AudioStream
@export var sound_pressed : AudioStream
@export var sound_slider_changed : AudioStream 

var hover_audio_stream_player : AudioStreamPlayer = AudioStreamPlayer.new()
var toggle_audio_stream_player : AudioStreamPlayer = AudioStreamPlayer.new()
var pressed_audio_stream_player : AudioStreamPlayer = AudioStreamPlayer.new()
var slider_changed_audio_stream_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	# Wait 1 frame just for skip all unwanted signals
	await get_tree().process_frame
	
	_prepare_audio_stream_player(hover_audio_stream_player, sound_hover)
	_prepare_audio_stream_player(toggle_audio_stream_player, sound_toggled_off)
	_prepare_audio_stream_player(pressed_audio_stream_player, sound_pressed)
	_prepare_audio_stream_player(slider_changed_audio_stream_player, sound_slider_changed)
	
	_connect_all()

func _connect_all():
	var childs = SceneTreeUtils.get_all_children(get_parent(), [])
	
	for child in childs:
		if child is BaseButton:
			if child is CheckButton or child is CheckBox:
				child.toggled.connect(func (value : bool):
					if value:
						toggle_audio_stream_player.stream = sound_toggled_on
					else:
						toggle_audio_stream_player.stream = sound_toggled_off
					toggle_audio_stream_player.play()
					)
			else:
				child.pressed.connect(pressed_audio_stream_player.play)
		elif child is TabContainer:
			child.tab_hovered.connect(hover_audio_stream_player.play)
			child.tab_clicked.connect(pressed_audio_stream_player.play)
		elif child is Slider:
			
			child.value_changed.connect(func (_value : float):
				slider_changed_audio_stream_player.play()
				)
		if child is Slider or child is BaseButton:
			child.mouse_entered.connect(hover_audio_stream_player.play)

func _prepare_audio_stream_player(asp : AudioStreamPlayer, stream : AudioStream):
	add_child(asp)
	
	asp.bus = &'SFX'
	asp.max_polyphony = 3
	asp.stream = stream
