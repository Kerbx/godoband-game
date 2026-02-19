extends TerminalCommand

func _init():
	command_name = "login"
	description = "Login as a user"
	required_access_level = TerminalSession.AccessLevel.GUEST

func execute(terminal, session, args):
	if args.size() == 0:
		terminal._print("Usage: login <username>")
		return
	
	session.user = args[0]
	session.access_level = TerminalSession.AccessLevel.USER
	terminal.current_mode = terminal.Mode.NORMAL
	terminal.text_pre = "> "
	terminal._print("Welcome, %s!" % session.user)
