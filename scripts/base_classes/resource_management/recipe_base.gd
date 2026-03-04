class_name Recipe
extends Resource


@export var id: String = ""
@export var display_name: String = ""
@export_multiline var description: String = ""
@export var inputs: Array[RecipeItem] = []
@export var outputs: Array[RecipeItem] = []
@export var processing_time: float = 1.0
@export var required_machine: String = ""
@export var energy_cost: float = 1.0


func _init(_id: String = "", _display_name: String = "",
			_description: String = "", _inputs: Array[RecipeItem] = [],
			_outputs: Array[RecipeItem] = [], _processing_time: float = 1.0,
			_required_machine: String = "", _energy_cost: float = 1.0) -> void:
	id = _id
	display_name = _display_name
	description = _description
	inputs = _inputs
	outputs = _outputs
	processing_time = _processing_time
	required_machine = _required_machine
	energy_cost = _energy_cost


func can_produce(available_resources: Dictionary) -> bool:
	for input_item in inputs:
		var resource_id = input_item.resource.id
		var required_amount = input_item.amount
		if not available_resources.has(resource_id) or available_resources[resource_id] < required_amount:
			return false
	return true


func get_inputs() -> Dictionary:
	var result = {}
	for input_item in inputs:
		result[input_item.resource.id] = input_item.amount

	return result


func get_outputs() -> Dictionary:
	var result = {}
	for output_item in outputs:
		result[output_item.resource.id] = output_item.amount

	return result


func get_info() -> Dictionary:
	return {
		"id": id,
		"display_name": display_name,
		"description": description,
		"inputs": inputs,
		"outputs": outputs,
		"processing_time": processing_time,
		"required_machine": required_machine,
		"energy_cost": energy_cost,
	}
