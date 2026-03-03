extends VBoxContainer

@onready var health_bar: TextureProgressBar = %health_bar
@onready var lube_bar: TextureProgressBar = %lube_bar
@onready var energy_bar: TextureProgressBar = %energy_bar
@onready var reserve_bar: TextureProgressBar = %reserve_bar


#----------- Init signals connection ------------
func _ready() -> void:
	EventBus.player_health_has_changed.connect(
		_on_player_health_has_changed)
	EventBus.player_lube_has_changed.connect(
		_on_player_lube_has_changed)
	EventBus.player_energy_has_changed.connect(
		_on_player_energy_has_changed)
	EventBus.player_reserve_energy_has_changed.connect(
		_on_player_reserve_energy_has_changed)

#----------- Handlers ------------
func _on_player_health_has_changed(value : float):
	health_bar.value = value

func _on_player_lube_has_changed(value : float):
	lube_bar.value = value

func _on_player_energy_has_changed(value : float):
	energy_bar.value = value

func _on_player_reserve_energy_has_changed(value : float):
	reserve_bar.value = value
