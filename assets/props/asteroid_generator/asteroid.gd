extends Asteroid

@onready var interact: Sprite3D = $interact
@onready var animation_player: AnimationPlayer = $interact/AnimationPlayer


var can_interact: bool = false

var player: PlayerOutsideBase

func _ready() -> void:
	_apply()
	interact.hide()



func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed('interact_primary') and can_interact:
		print('start minigame')
		player.interact_mode_enter.emit(self)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is PlayerOutsideBase:
		interact.show()
		animation_player.play('loop')
		can_interact = true
		player = body


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is PlayerOutsideBase:
		interact.hide()
		animation_player.stop()
		can_interact = false
		player = null
		
