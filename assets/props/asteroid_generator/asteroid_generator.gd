extends Node3D
class_name Asteroid

@export var _seed:int
@export var color_ramp:Gradient
@export var textures:Array[Texture2D]
#@export var apply:bool = false

@export var mesh: MeshInstance3D

#func _ready() -> void:
	#apply = true

#func _process(delta: float) -> void:
	#if apply:
		#_apply()
		#apply = false

func _apply():
	##Generates new asteroid
	_seed = randi() * randi_range(-1, 1)
	var new_noise:NoiseTexture2D = NoiseTexture2D.new()
	new_noise.noise = FastNoiseLite.new()
	new_noise.noise.seed = _seed
	new_noise.noise.frequency = 0.07
	new_noise.color_ramp = color_ramp
	new_noise.in_3d_space = true
	
	var texture:Texture2D = textures.pick_random()
	
	var material:ShaderMaterial = mesh.get_active_material(0)
	material.set_shader_parameter('noise_tex', new_noise)
	material.set_shader_parameter('tex', texture)
	
	var m_scale = randf_range(0.7,2)
	mesh.scale = Vector3(m_scale, m_scale, m_scale)
	
	
	print('applied')
