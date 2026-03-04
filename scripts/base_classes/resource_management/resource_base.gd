class_name BaseResource
extends Resource


@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var icon: Texture2D
@export var mass: float = 1.0
@export var stack: int = 10
@export_enum("raw", "refined", "component", "product") var category: String = "raw"


func _init(_id: String = "", _display_name: String = "",
			_description: String = "", _mass: float = 1.0,
			_stack: int = 10, _category: String = "raw") -> void:
	id = _id
	display_name = _display_name
	description = _description
	mass = _mass
	stack = _stack
	category = _category


func get_info() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"description": description,
		"mass": mass,
		"stack": stack,
		"category": category,
	}
