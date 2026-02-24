extends InteractionAction

func execute(_interactor: Node) -> void:
	owner.state_machine.change_state("active_state")
