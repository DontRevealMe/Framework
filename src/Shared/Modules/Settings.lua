return {
	Debugger = {
		PrintDebug = false; -- Wether or not debug messages get printed or not.
		Format = {
			TagFormat = "[%s]"; -- What a tag would look like. This is used for [CRITICAL], [Server\Script\...]
			Format = "%s: %s"; -- How you wanna divide it. ie [TAG] [TAG]: MESSAGE
			CustomFormats = {
				Error = "%s %s\n\n%s"; -- If you wanna add exceptions to the format rule above, do it here. There 5 types of messages which are: Message, Debugging, Warning, Error, and Critical
				Critical = "%s %s\n\n%s"
			},
		}
	}
}