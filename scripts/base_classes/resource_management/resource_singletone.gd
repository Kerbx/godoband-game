extends Node


var resources: Dictionary = {}
var recipes: Dictionary = {}
var recipes_by_machine: Dictionary = {}


func _ready() -> void:
	_init_resources()
	_init_recipes()


func _init_resources() -> void:
	_register_resource(BaseResource.new("iron_ore",
										"Iron Ore",
										"Kusok zheleza",
										10.0,
										100,
										"raw"))
	# да, я люблю сокращать и писать без ввода лишних переменных.
	# можете не кидаться тапками, это лишь пример.

	var iron_ingot = BaseResource.new("iron_ingot", "Iron Ingot", "pizdec ustal", 5.0, 50, "refined")
	_register_resource(iron_ingot)

	var iron_asteroid = create_asteroid("asteroid_iron", "Iron Asteroid", "iron", 1000.0, [
		{"resource_id": "iron_ore", "percentage": 45.0},
		{"resource_id": "carbon", "percentage": 15.0},
		{"resource_id": "silicon", "percentage": 10.0}
	])
	_register_resource(iron_asteroid)


func _init_recipes() -> void:
	for resource_id in resources:
		var resource = resources[resource_id]
		if resource is AsteriodResource:
			var recipe = resource.get_refining_recipe()
			_register_recipe(recipe)

	create_recipe(
		"smelt_iron",
		"Smelt Iron Ingot",
		"smelter",
		[{"resource_id": "iron_ore", "amount": 1.0}],
		[{"resource_id": "iron_ingot", "amount": 1.0}],
		2.0
	)
	
	create_recipe(
		"smelt_steel",
		"Make a STEEL (not STONE (and not ROCK))",
		"smelter",
		[
			{"resource_id": "iron_ingot", "amount": 2.0},
			{"resource_id": "carbon", "amount": 5.0},
		],
		[{"resource_id": "steel_ignot", "amount": 1.0}],
		5.0
	)

func create_asteroid(id: String, name: String, type: String, mass: float, outputs: Array) -> AsteriodResource:
	var asteroid = AsteriodResource.new(id, name, "", mass, 10, type)

	for output in outputs:
		var ref_output = RefiningOutput.new(resources[output["resource_id"]], output["percentage"])
		asteroid.refining_outputs.append(ref_output)
	return asteroid
	

func create_recipe(id: String, name: String, machine_type: String,
					inputs: Array, outputs: Array, time: float) -> Recipe:
	var recipe = Recipe.new(id, name)
	recipe.required_machine = machine_type
	recipe.processing_time = time

	for input in inputs:
		var item = RecipeItem.new(resources[input["resource_id"]], input["amount"])
		recipe.inputs.append(item)
	for output in outputs:
		var item = RecipeItem.new(resources[output["resource_id"]], output["amount"])
		recipe.outputs.append(item)

	_register_recipe(recipe)
	return recipe


func _register_resource(resource: BaseResource) -> void:
	resources[resource.id] = resource


func _register_recipe(recipe: Recipe) -> void:
	recipes[recipes.id] = recipe
	if not recipes_by_machine.has(recipe.required_machine):
		recipes_by_machine[recipe.required_machine] = []
	recipes_by_machine[recipe.required_machine].append(recipe)


func get_resource(resource_id: String) -> BaseResource:
	return resources.get(resource_id, null)


func get_recipe(recipe_id: String) -> Recipe:
	return recipes.get(recipe_id, null)


func get_recipes_for_machine(machine_type: String) -> Array:
	return recipes_by_machine.get(machine_type, [])


func get_recipes_producing(resource_id: String) -> Array:
	var result = []
	for recipe in recipes.values():
		for output in recipe.outputs:
			if output.resource.id == resource_id:
				result.append(recipe)
				break
	return result


func get_recipes_consuming(resource_id: String) -> Array:
	var result = []
	for recipe in recipes.values():
		for input in recipe.inputs:
			if input.resource.id == resource_id:
				result.append(recipe)
				break
	return result
