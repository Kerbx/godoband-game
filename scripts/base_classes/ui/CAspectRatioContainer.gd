@tool
class_name CAspectRatioContainer
extends AspectRatioContainer

##Calculate be dividing width by height OR just 16.0/9.0 or other aspect ratios
@export var maximum_aspect_ratio : float = 1.7778 

func _ready() -> void:
	ratio = maximum_aspect_ratio
	
	if Engine.is_editor_hint():
		return
	
	_update_interface_ratio()
	get_viewport().size_changed.connect(_update_interface_ratio)


func _update_interface_ratio():
	self.ratio = minf(float(self.size.x) / float(self.size.y), maximum_aspect_ratio)
