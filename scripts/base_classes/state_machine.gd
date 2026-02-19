extends Node
class_name StateMachine


@export var init_state : State


var current_state : State
var prev_state : State
var states : Dictionary


func _ready() -> void:
	# Инициализация состояний
	for state : State in get_children():
		states[state.name.to_lower()] = state
		state.state_machine = self
		
	# Установка начального состояния
	if init_state != null:
		current_state = init_state
	elif get_child(0) != null:
		current_state = get_child(0)


func change_state(new_state_name : String):
	prev_state = current_state
	if new_state_name == null:
		push_warning("Не указано состояние для перехода")
		return
	
	var new_state = states[new_state_name]
	if not new_state is State:
		push_warning("Указано неверное состояние для перехода")
		return
	
	if prev_state:
		prev_state.exit()
	
	current_state = new_state
	current_state.enter()


func _process(delta: float) -> void:
	current_state.update(delta)
	
	
func _physics_process(delta: float) -> void:
	current_state.phyisic_update(delta)
	
