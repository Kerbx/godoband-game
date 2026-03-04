class_name RefiningOutput
extends Resource


@export var resource: BaseResource
@export_range(0.0, 100.0) var percentage: float = 100.0


func _init(_resource: BaseResource = null, _percentage: float = 100.0) -> void:
	resource = _resource
	percentage = _percentage
