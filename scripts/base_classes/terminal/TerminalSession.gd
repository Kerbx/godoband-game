extends RefCounted
class_name TerminalSession

enum AccessLevel {
	GUEST,
	USER,
	ADMIN
}

var user : String = ""
var access_level : AccessLevel = AccessLevel.GUEST
