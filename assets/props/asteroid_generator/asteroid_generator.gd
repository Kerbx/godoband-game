@tool
extends Node3D

@export var seed:int
@export var color_ramp:Gradient
@export var textures:Array[Texture2D]
@export var apply:bool = false

@onready var cube: MeshInstance3D = $Cube
func _process(delta: float) -> void:
	if apply:
		_apply()
		apply = false

func _apply():
	var new_noise:NoiseTexture2D = NoiseTexture2D.new()
	new_noise.noise = FastNoiseLite.new()
	new_noise.noise.seed = seed
	new_noise.noise.frequency = 0.07
	new_noise.color_ramp = color_ramp
	new_noise.in_3d_space = true
	
	var texture:Texture2D = textures.pick_random()
	
	var material:ShaderMaterial = cube.get_active_material(0)
	material.set_shader_parameter('noise_tex', new_noise)
	material.set_shader_parameter('tex', texture)
	
	
	print('applied')
