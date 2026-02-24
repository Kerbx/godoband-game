class_name InteractableObject
extends PhysicsBody3D

var actions: Array[InteractionAction] = []

func _ready():
	for child in get_children():
		if child is InteractionAction:
			actions.append(child)
