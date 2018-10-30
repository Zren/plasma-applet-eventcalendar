// Version 3

import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
	id: executable
	engine: "executable"
	connectedSources: []
	onNewData: {
		var exitCode = data["exit code"]
		var exitStatus = data["exit status"]
		var stdout = data["stdout"]
		var stderr = data["stderr"]
		exited(sourceName, exitCode, exitStatus, stdout, stderr)
		disconnectSource(sourceName) // cmd finished
	}

	signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)

	function trimOutput(stdout) {
		return stdout.replace('\n', ' ').trim()
	}

	property var listeners: ({}) // Empty Map

	function exec(cmd, callback) {
		if (typeof callback === 'function') {
			if (listeners[cmd]) { // Our implementation only allows 1 callback per command.
				exited.disconnect(listeners[cmd])
				delete listeners[cmd]
			}
			var listener = execCallback.bind(executable, callback)
			exited.connect(listener)
			listeners[cmd] = listener
		}
		connectSource(cmd)
	}

	function execCallback(callback, cmd, exitCode, exitStatus, stdout, stderr) {
		exited.disconnect(listeners[cmd])
		delete listeners[cmd]
		callback(cmd, exitCode, exitStatus, stdout, stderr)
	}
}
