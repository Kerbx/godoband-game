class_name Interactor
extends ShapeCast3D

@export var disabled : bool = false :
	set(value):
		set_process_input(!value)
		disabled = value

@export var primary_input_action: StringName = &"interact_primary"
@export var secondary_input_action: StringName = &"interact_secondary"

var _current_target: InteractableObject
var _press_action: InteractionAction
var _hold_action: InteractionAction

var _hold_time := 0.0
var _is_tracking := false
var _current_input_type: InteractionAction.INTERACTION_INPUT

func _ready() -> void:
	add_exception(get_owner())


func _process(delta: float) -> void:
	if not _is_tracking:
		return
	
	if not is_instance_valid(_current_target):
		_reset()
		return
	
	_hold_time += delta
	
	if _hold_action and _hold_time >= _hold_action.hold_duration:
		if _hold_action.can_execute(self):
			_hold_action.execute(self)
		_reset()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(primary_input_action):
		_try_start(InteractionAction.INTERACTION_INPUT.PRIMARY_INTERACTION)
	
	if event.is_action_pressed(secondary_input_action):
		_try_start(InteractionAction.INTERACTION_INPUT.SECONDARY_INTERACTION)
	
	if event.is_action_released(primary_input_action):
		_try_release(InteractionAction.INTERACTION_INPUT.PRIMARY_INTERACTION)
	
	if event.is_action_released(secondary_input_action):
		_try_release(InteractionAction.INTERACTION_INPUT.SECONDARY_INTERACTION)


func _try_start(
	input_type: InteractionAction.INTERACTION_INPUT
) -> void:
	
	var target := _get_focused_object()
	if not target:
		return
	
	var actions := _collect_actions(target, input_type)
	if actions.is_empty():
		return
	
	_current_target = target
	_current_input_type = input_type
	
	_press_action = null
	_hold_action = null
	
	for action in actions:
		if action.hold_duration > 0.0:
			_hold_action = action
		else:
			_press_action = action
	
	_hold_time = 0.0
	_is_tracking = true


func _try_release(
	input_type: InteractionAction.INTERACTION_INPUT
) -> void:
	
	if not _is_tracking:
		return
	
	if input_type != _current_input_type:
		return
	
	if _hold_action and _hold_time >= _hold_action.hold_duration:
		_reset()
		return
	
	if _press_action:
		if _press_action.can_execute(self):
			_press_action.execute(self)
	
	_reset()


func _collect_actions(
	target: InteractableObject,
	input_type: InteractionAction.INTERACTION_INPUT
) -> Array:
	
	var result: Array = []
	
	for action in target.actions:
		if action.interaction == input_type:
			result.append(action)
	
	return result


func _reset() -> void:
	_current_target = null
	_press_action = null
	_hold_action = null
	_hold_time = 0.0
	_is_tracking = false


func _get_focused_object() -> InteractableObject:
	for collider_index: int in get_collision_count():
		if get_collider(collider_index) is InteractableObject:
			return get_collider(collider_index) 
	return null
