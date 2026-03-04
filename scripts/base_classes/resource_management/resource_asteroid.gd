class_name AsteriodResource
extends BaseResource


# ya uzhe zaebalsya.....
@export var asteroid_type: String = ""
@export var refining_outputs: Array[RefiningOutput] = []


func _init(_id: String = "", _display_name: String = "",
			_description: String = "", _mass: float = 1.0,
			_stack: int = 10, _type: String = "") -> void:
	super._init(_id, _display_name, _description, _mass, _stack,)
	asteroid_type = _type


func get_refining_recipe() -> Recipe:
	var recipe = Recipe.new("refine_" + id)
	recipe.display_name = "Refine " + display_name
	recipe.description = "Process asteroid to extract raw ore and other..."
	recipe.required_machine = "" # бля, надо вспомнить....
	recipe.processing_time = mass / 100.0

	var input = RecipeItem.new(self, 1.0)
	recipe.inputs.append(input)

	for refining_output in refining_outputs:
		var output = RecipeItem.new(refining_output.resource, mass * refining_output.percentage / 100)
		recipe.outputs.append(output)

	return recipe


func get_refining_info() -> Dictionary:
	var outputs = {}
	for refining_output in refining_outputs:
		var amount = mass * refining_output.percentage / 100.0
		outputs[refining_output.resource.id] = {
			"amount": amount,
			"percentage": refining_output.percentage,
		}
	return {
		"asteroid_type": asteroid_type,
		"mass": mass,
		"outputs": outputs,
	}
