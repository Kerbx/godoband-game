## A single interaction prompt widget displayed in the UI when the player
## focuses on an [InteractableObject].[br][br]
##
## Shows the action label and the bound input key, and optionally displays
## a [ProgressBar] for hold-type interactions that fills over time
## while the player holds the input.
class_name InteractPrompt
extends Control

## The label displaying the action name and bound input key.
@onready var label : Label = %Label
## The progress bar shown during hold-type interactions.
@onready var progress : ProgressBar = %ProgressBar

## Whether this prompt represents a hold-type interaction.
var _is_hold : bool = false
## The input type (primary or secondary) this prompt is bound to.
var _input_type : InteractionAction.INTERACTION_INPUT
## The internal action name identifier for this prompt.
var _action_name: StringName

## Public read-accessible input type, mirrored from [member _input_type] after setup.
var input_type : InteractionAction.INTERACTION_INPUT
## Public read-accessible action name, mirrored from [member _action_name] after setup.
var action_name: StringName

## Initializes the prompt UI element from a data dictionary.
## Expects keys: [code]text[/code], [code]input[/code], [code]action_name[/code], [code]hold[/code].
## Sets up the label, progress bar, and input icon based on the provided data.
func setup(data: Dictionary) -> void:
	label.text = data[&"text"]
	_input_type = data[&"input"]
	_action_name = data[&"action_name"]
	input_type = _input_type
	action_name = _action_name
	_is_hold = data[&"hold"]
	progress.min_value = 0.0
	progress.max_value = 1.0
	progress.value = 0.0
	_set_input_icon(data[&"input"])

## Updates the hold progress bar with the given [param value] clamped to [code][0.0, 1.0][/code].
## Has no effect if this prompt is not a hold-type interaction.
func update_hold(value: float) -> void:
	if _is_hold:
		progress.value = clamp(value, 0.0, 1.0)

## Appends the bound input key to the label text based on [param p_input_type].
## Looks up the first event bound to the corresponding action in [InputMap]
## and formats the label as [code]"text [KEY]"[/code].
func _set_input_icon(p_input_type) -> void:
	var _f_action_name = ""
	match p_input_type:
		InteractionAction.INTERACTION_INPUT.PRIMARY_INTERACTION:
			_f_action_name = &"interact_primary"
		InteractionAction.INTERACTION_INPUT.SECONDARY_INTERACTION:
			_f_action_name = &"interact_secondary"
	var events = InputMap.action_get_events(_f_action_name)
	if events.size() > 0:
		var event = events[0]
		label.text = "%s [%s]" % [label.text, event.as_text().trim_suffix(" - Physical")]
