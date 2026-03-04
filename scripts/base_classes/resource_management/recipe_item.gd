class_name RecipeItem
extends BaseResource


@export var resource: BaseResource
@export var amount: float = 1.0


func _init(_resource: BaseResource = null, _amount: float = 1.0) -> void:
	resource = _resource
	amount = _amount
