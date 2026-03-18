extends Node3D

@export var ship: PlayerOutsideBase
@export var station: Node3D

@onready var label_3d: Label3D = $"Sprite3D/Label3D"
@onready var sprite_3d: Sprite3D = $"Sprite3D"


func _ready():
	label_3d.text = str(snapped(ship.global_position.distance_to(station.global_position), 0.01))
	
  
func _process(_delta):
	if !get_viewport().get_camera_3d().is_position_in_frustum(station.global_position):
		show()
		self.look_at(station.position)
		global_position = ship.global_position
		label_3d.text = str(snapped(ship.global_position.distance_to(station.global_position), 0.01))

		
	else:
		hide()
