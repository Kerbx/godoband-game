class_name MachineProcessor
extends Node


@export var machine_type: String = ""

var current_recipe: Recipe = null
var progress: float = 0.0
var is_active: bool = false
var input_inventory: Dictionary = {}
var output_inventory: Dictionary = {}

signal production_started(recipe: Recipe)
signal production_finished(recipe: Recipe, outputs: Dictionary)


func _process(delta: float) -> void:
	if not is_active or current_recipe == null:
		return

	progress += delta / current_recipe.processing_time

	if progress >= 1.0:
		complete_production()


func set_recipe(recipe: Recipe) -> bool:
	if recipe.required_machine != machine_type:
		push_error("Not this.")
		return false
	current_recipe = recipe
	progress = 0.0
	is_active = false
	return true


func add_input_resource(resource_id: String, amount: float) -> void:
	if not input_inventory.has(resource_id):
		input_inventory[resource_id] = 0.0
	input_inventory[resource_id] += amount


func extract_output_resource(resource_id: String, amount: float) -> float:
	if not output_inventory.has(resource_id):
		return 0.0
	var available = output_inventory[resource_id]
	var extracted = min(available, amount)
	output_inventory[resource_id] -= extracted

	if output_inventory[resource_id] <= 0:
		output_inventory.erase(resource_id)

	return extracted


func start_production() -> bool:
	if is_active:
		return false
	if current_recipe == null:
		return false
	if not current_recipe.can_produce(input_inventory):
		return false
	for input_item in current_recipe.inputs:
		var resource_id = input_item.resource.id
		input_inventory[resource_id] -= input_item.amount

		if input_inventory[resource_id] <= 0:
			input_inventory.erase(resource_id)

	is_active = true
	progress = 0.0
	production_started.emit(current_recipe)
	return true


func complete_production() -> void:
	if current_recipe == null:
		return
	var produced_items = {}

	for output_item in current_recipe.outputs:
		var resource_id = output_item.resource.id
		if not output_inventory.has(resource_id):
			output_inventory[resource_id] = 0.0
		output_inventory[resource_id] += output_item.amount
		produced_items[resource_id] = output_item.amount

	production_finished.emit(current_recipe, produced_items)

	is_active = false
	progress = 0.0

	start_production()


func cancel_production() -> void:
	if not is_active:
		return

	if current_recipe:
		for input_item in current_recipe.inputs:
			add_input_resource(input_item.resource.id, input_item.amount)

	is_active = false
	progress = 0.0


func get_status() -> Dictionary:
	return {
		"machine_type": machine_type,
		"is_active": is_active,
		"current_recipe": current_recipe.id if current_recipe else null,
		"progress": progress,
		"input_inventory": input_inventory.duplicate(),
		"output_inventory": output_inventory.duplicate(),
	}
