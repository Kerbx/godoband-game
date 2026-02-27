## A [ShapeCast3D]-based interaction detector that tracks player input and executes
## [InteractionAction] nodes on focused [InteractableObject] instances.[br][br]
##
## Each frame it detects which [InteractableObject] is within the cast shape,
## updates the UI prompts accordingly, and listens for primary and secondary input actions.
## Interactions are split into two types:[br]
## - [b]Press[/b] — executed immediately on input release.[br]
## - [b]Hold[/b] — executed after the input is held for [member InteractionAction.hold_duration] seconds.[br][br]
##
## Only one interaction can be active at a time. Starting a new interaction while
## one is already tracked is blocked until the current one is released or completed.
class_name Interactor
extends ShapeCast3D

## If [code]true[/code], disables all input processing and clears any active interaction state.
@export var disabled : bool = false :
	set(value):
		set_process_input(!value)
		disabled = value
		if value:
			_on_disabled()
		else:
			_on_enabled()

## Input action name used for primary interaction (e.g. left mouse button or gamepad face button).
@export var primary_input_action: StringName = &"interact_primary"
## Input action name used for secondary interaction (e.g. right mouse button or gamepad shoulder).
@export var secondary_input_action: StringName = &"interact_secondary"

## The interactable object currently being interacted with.
var _current_target: InteractableObject
## Collected press-type actions waiting to be executed on input release.
var _press_actions: Array[InteractionAction] = []
## Active hold-type actions indexed by action name, each storing action reference, input type, and elapsed time.
var _hold_states : Dictionary = {}

## Accumulated hold time. Reserved for future use; active hold timing is tracked per-action in [member _hold_states].
var _hold_time : float = 0.0
## Whether an interaction is currently being tracked (input was pressed and not yet released).
var _is_tracking : bool = false
## The input type (primary or secondary) of the currently tracked interaction.
var _current_input_type: InteractionAction.INTERACTION_INPUT

## The [InteractableObject] currently in focus (inside the shape cast).
var _focused_object: InteractableObject

## Excludes the owner node from shape cast collisions to prevent self-detection.
func _ready() -> void:
	add_exception(get_owner())

## Called every frame. Skips all logic if [member disabled] is true.
## Runs focus detection, input polling, and hold progress updates.
func _process(delta : float) -> void:
	if disabled:
		return

	_update_focus()
	_update_input()
	_handle_hold(delta)

## Polls input actions each frame and routes just-pressed or just-released
## events to [method _try_start] or [method _try_release] respectively.
func _update_input() -> void:
	if Input.is_action_just_pressed(primary_input_action):
		_try_start(InteractionAction.INTERACTION_INPUT.PRIMARY_INTERACTION)
	elif Input.is_action_just_released(primary_input_action):
		_try_release(InteractionAction.INTERACTION_INPUT.PRIMARY_INTERACTION)

	if Input.is_action_just_pressed(secondary_input_action):
		_try_start(InteractionAction.INTERACTION_INPUT.SECONDARY_INTERACTION)
	elif Input.is_action_just_released(secondary_input_action):
		_try_release(InteractionAction.INTERACTION_INPUT.SECONDARY_INTERACTION)

## Advances hold timers for all active hold-type actions by [param delta].
## Emits UI progress updates each frame and executes completed actions,
## then removes them from [member _hold_states].
func _handle_hold(delta : float) -> void:
	var completed_actions : Array = []

	for action_name in _hold_states.keys():
		if not action_name in _hold_states:
			continue
		
		var state = _hold_states[action_name]
		state[&"time"] += delta
		
		var action = state[&"action"]
		var progress = state[&"time"] / action.hold_duration
		
		EventBus.ui_update_promts.emit([{
			&"action_name": action.action_name,
			&"input": state[&"input_type"],
			&"progress": clamp(progress, 0.0, 1.0)
		}])
		
		if progress >= 1.0:
			if is_instance_valid(action) and action.can_execute(self):
				action.execute(self)
			completed_actions.append(action_name)
	
	for action_name in completed_actions:
		if action_name in _hold_states:
			_clear_hold(action_name)

## Removes a hold action from [member _hold_states] by [param action_name]
## and emits a UI update to reset its progress bar to zero.
func _clear_hold(action_name: StringName) -> void:
	var action = _hold_states[action_name].get(&"action") if action_name in _hold_states else null
	var input_type = _hold_states[action_name].get(&"input_type") if action_name in _hold_states else null
	_hold_states.erase(action_name)
	
	var update_data = {
		&"input": input_type,
		&"progress": 0.0
	}
	
	if action:
		update_data[&"action_name"] = action.action_name
	
	EventBus.ui_update_promts.emit([update_data])

## Begins tracking an interaction for the given [param input_type].
## Collects matching actions from the focused object and sorts them into
## hold actions (added to [member _hold_states]) or press actions (added to [member _press_actions]).
## Does nothing if tracking is already active or no valid target is focused.
func _try_start(input_type) -> void:
	var target := _get_focused_object()
	
	if _is_tracking:
		return
	
	if not target:
		return
	
	var actions := _collect_actions(target, input_type)
	
	if actions.is_empty():
		return
	
	_is_tracking = true
	_current_input_type = input_type
	
	for action in actions:
		if action.hold_duration > 0.0:
			_hold_states[action.action_name] = {
				&"action": action,
				&"input_type": input_type,
				&"time": 0.0
			}
		else:
			_press_actions.append(action)

## Finalizes the interaction for the given [param input_type] on input release.
## Cancels any incomplete hold actions, executes all pending press actions,
## and resets the interaction state. Does nothing if [param input_type] does not
## match the currently tracked input.
func _try_release(input_type: InteractionAction.INTERACTION_INPUT) -> void:
	if not _is_tracking:
		return
	
	if input_type != _current_input_type:
		return
	
	var hold_actions_to_clear = []
	for action_name in _hold_states.keys():
		if _hold_states[action_name].get(&"input_type") == input_type:
			hold_actions_to_clear.append(action_name)
	
	for action_name in hold_actions_to_clear:
		_clear_hold(action_name)
	
	for action in _press_actions:
		if action.can_execute(self):
			action.execute(self)
	
	_reset()

## Returns all [InteractionAction] nodes from [param target] that match the given [param input_type].
func _collect_actions(
	target: InteractableObject,
	input_type: InteractionAction.INTERACTION_INPUT
) -> Array[InteractionAction]:
	var result: Array[InteractionAction] = []
	
	for action in target.actions:
		if action.interaction == input_type:
			result.append(action)
	
	return result

## Clears all active interaction state: target, press actions, hold time, and tracking flag.
func _reset() -> void:
	_current_target = null
	_press_actions.clear()
	_hold_time = 0.0
	_is_tracking = false

## Returns the first [InteractableObject] found among current shape cast colliders,
## or [code]null[/code] if none is detected.
func _get_focused_object() -> InteractableObject:
	for collider_index: int in get_collision_count():
		if get_collider(collider_index) is InteractableObject:
			return get_collider(collider_index)
	return null

## Detects changes in the focused [InteractableObject] each frame.
## Emits [signal EventBus.ui_draw_promts] when a new object is focused,
## and [signal EventBus.ui_reset_promts] when focus is lost or the object is gone.
func _update_focus() -> void:
	var new_target : InteractableObject = _get_focused_object()
	
	if not new_target:
		_focused_object = null
		_on_disabled()
	
	if new_target == _focused_object:
		return
	
	_focused_object = new_target
	
	if not _focused_object:
		EventBus.ui_reset_promts.emit([])
		return
	
	var prompts : Array[Dictionary] = []
	
	for action in _focused_object.actions:
		prompts.append(action.get_prompt_data())
	
	EventBus.ui_draw_promts.emit(prompts)

## Called when [member disabled] is set to [code]true[/code].
## Resets all UI prompts, clears hold states, and resets interaction tracking.
func _on_disabled() -> void:
	EventBus.ui_reset_promts.emit([])
	_hold_states.clear()
	_reset()

## Called when [member disabled] is set to [code]false[/code].
## Clears the cached focused object and re-runs focus detection.
func _on_enabled() -> void:
	_focused_object = null
	_update_focus()
