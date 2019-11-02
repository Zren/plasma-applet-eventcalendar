// Version 5

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
	id: executable
	engine: "executable"
	connectedSources: []
	onNewData: {
		var cmd = sourceName
		var exitCode = data["exit code"]
		var exitStatus = data["exit status"]
		var stdout = data["stdout"]
		var stderr = data["stderr"]
		var listener = listeners[cmd]
		if (listener) {
			listener(cmd, exitCode, exitStatus, stdout, stderr)
		}
		exited(cmd, exitCode, exitStatus, stdout, stderr)
		disconnectSource(sourceName) // cmd finished
	}

	signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)

	function trimOutput(stdout) {
		return stdout.replace(/\n/g, ' ').trim()
	}

	property var listeners: ({}) // Empty Map

	// Note that this has not gone under a security audit.
	// You probably shouldn't trust 3rd party input.
	function wrapToken(token) {
		token = "" + token
		// ' => '"'"' to escape the single quotes
		token = token.replace(/\'/g, "\'\"\'\"\'")
		token = "\'" + token + "\'"
		return token
	}

	function exec(cmd, callback) {
		if (Array.isArray(cmd)) {
			cmd = cmd.map(wrapToken)
			cmd = cmd.join(' ')
		}
		if (typeof callback === 'function') {
			if (listeners[cmd]) { // Our implementation only allows 1 callback per command.
				exited.disconnect(listeners[cmd])
				delete listeners[cmd]
			}
			var listener = execCallback.bind(executable, callback)
			listeners[cmd] = listener
		}
		// console.log('cmd', cmd)
		connectSource(cmd)
	}

	function execCallback(callback, cmd, exitCode, exitStatus, stdout, stderr) {
		delete listeners[cmd]
		callback(cmd, exitCode, exitStatus, stdout, stderr)
	}

	//--- Tests
	function test() {
		exec(['notify-send', 'test', '$(notify-send escape1)'])
		exec(['notify-send', 'test', '`notify-send escape2`'])
		exec(['notify-send', 'test', '\'; notify-send escape3;\''])
		exec(['notify-send', 'test', '\\\'; notify-send escape4;\\\''])
	}
	// Component.onCompleted: test()
}
