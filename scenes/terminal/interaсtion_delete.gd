extends InteractionAction

func _init() -> void:
	prompt_text = "Delete Terminal"

func execute(_interactor: Node) -> void:
	owner.queue_free()
