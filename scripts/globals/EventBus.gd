extends Node

signal update_settings
signal update_navigation_mesh

signal ui_draw_promts(prompts : Array)
signal ui_update_promts(prompts : Array)
signal ui_reset_promts(prompts : Array)

signal player_state_ui(enabled : bool)

signal player_health_has_changed(new_health_value : float)
signal player_lube_has_changed(new_lube_value : float)
signal player_energy_has_changed(new_energy_value : float)
signal player_reserve_energy_has_changed(new_reserv_energy_value : float)
