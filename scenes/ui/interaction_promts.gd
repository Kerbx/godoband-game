## Manages the interaction prompt UI by listening to [EventBus] signals
## and dynamically spawning, updating, and clearing [InteractPrompt] widgets.[br][br]
##
## Connects to three events on ready:[br]
## - [signal EventBus.ui_draw_promts] — rebuilds the prompt list for a new focused object.[br]
## - [signal EventBus.ui_update_promts] — updates hold progress on active prompts.[br]
## - [signal EventBus.ui_reset_promts] — clears all prompts when focus is lost.
class_name InteractionUI
extends VBoxContainer

## The scene instantiated for each individual interaction prompt.
@export var prompt_scene: PackedScene

## All currently displayed [InteractPrompt] instances.
var _active_prompts : Array = []

## Connects all relevant [EventBus] signals to their handlers.
func _ready() -> void:
	EventBus.ui_draw_promts.connect(_on_draw_prompts)
	EventBus.ui_update_promts.connect(_on_update_prompts)
	EventBus.ui_reset_promts.connect(_on_reset_prompts)

## Clears existing prompts and instantiates a new [InteractPrompt] for each
## entry in [param prompts], then calls [method InteractPrompt.setup] with its data.
func _on_draw_prompts(prompts: Array) -> void:
	_clear()
	for data in prompts:
		var prompt = prompt_scene.instantiate()
		self.add_child(prompt)
		prompt.setup(data)
		_active_prompts.append(prompt)

## Applies hold progress updates from [param updates] to matching active prompts.
## Matches by [code]action_name[/code] if present, otherwise falls back to [code]input[/code] type.
func _on_update_prompts(updates: Array) -> void:
	for update in updates:
		for prompt in _active_prompts:
			var matches : bool = false
			if &"action_name" in update and update[&"action_name"]:
				matches = prompt.action_name == update[&"action_name"]
			else:
				matches = prompt.input_type == update[&"input"]

			if matches:
				prompt.update_hold(update[&"progress"])

## Clears all active prompts. The [param _data] argument is unused
## but required to match the [EventBus] signal signature.
func _on_reset_prompts(_data) -> void:
	_clear()

## Frees all active [InteractPrompt] nodes and clears the tracking array.
func _clear() -> void:
	for prompt in _active_prompts:
		prompt.queue_free()
	_active_prompts.clear()
