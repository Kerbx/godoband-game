extends TerminalCommand

func _init():
	command_name = "help"
	description = "Show available commands"
	required_access_level = TerminalSession.AccessLevel.GUEST

func execute(terminal, session, _args):
	terminal._print("Available commands:")
	for cmd in terminal.command_map.values():
		if session.access_level >= cmd.required_access_level:
			terminal._print("%s - %s" % [cmd.command_name, cmd.description])
