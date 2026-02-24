class_name InteractionAction
extends Node

enum INTERACTION_INPUT {
	PRIMARY_INTERACTION,
	SECONDARY_INTERACTION
}

@export var action_name : StringName = &'nameholder'
@export var interaction: INTERACTION_INPUT
@export var hold_duration: float = 0.0

func can_execute(_interactor: Node) -> bool:
	return true

func execute(_interactor: Node) -> void:
	pass
