extends Resource
class_name TerminalCommand

@export var command_name : String
@export var description : String
@export var required_access_level : TerminalSession.AccessLevel = TerminalSession.AccessLevel.GUEST

func execute(_terminal, _session : TerminalSession, _args : PackedStringArray) -> void:
	pass
