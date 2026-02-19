extends TerminalCommand

func _init():
	command_name = "clear"
	description = "Clear the terminal log"
	required_access_level = TerminalSession.AccessLevel.GUEST

func execute(terminal, _session, _args):
	terminal.clear_log()
