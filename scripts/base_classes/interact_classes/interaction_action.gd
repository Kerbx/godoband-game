class_name InteractionAction
extends Node

## Defines the input button that triggers this action.
enum INTERACTION_INPUT {
	PRIMARY_INTERACTION,
	SECONDARY_INTERACTION
}

@export var action_name : StringName = &'nameholder'
@export var prompt_text : String = "placeholder"
@export var interaction: INTERACTION_INPUT
@export var hold_duration: float = 0.0

## Returns whether this action is allowed to execute for the given [param _interactor].
## Override in subclasses to add custom conditions.
func can_execute(_interactor: Node) -> bool:
	return true

## Executes the action logic for the given [param _interactor].
## Override in subclasses to implement behaviour.
func execute(_interactor: Node) -> void:
	pass

## Returns a dictionary with all data needed to display the interaction prompt in the UI.
## Includes action name, input type, label text, whether it is a hold interaction, and hold duration.
func get_prompt_data() -> Dictionary[StringName, Variant]:
	return {
		&"action_name": action_name,
		&"input": interaction,
		&"text": prompt_text,
		&"hold": hold_duration > 0.0,
		&"duration": hold_duration
	}
