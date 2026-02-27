## A physical object in the world that can be interacted with by an [Interactor].[br][br]
##
## Automatically collects all child [InteractionAction] nodes on ready,
## which are then read by [Interactor] to determine available interactions
## when this object is in focus.
class_name InteractableObject
extends PhysicsBody3D

## All [InteractionAction] nodes that are direct children of this object.
## Populated automatically in [method _ready].
var actions: Array[InteractionAction] = []

## Scans direct children and collects all [InteractionAction] instances into [member actions].
func _ready() -> void:
	_update_actions()

## Clears and repopulates [member actions] by scanning current direct children.
## Call this after adding or removing [InteractionAction] children at runtime.
func _update_actions() -> void:
	actions.clear()
	
	for child in get_children():
		if child is InteractionAction:
			actions.append(child)
