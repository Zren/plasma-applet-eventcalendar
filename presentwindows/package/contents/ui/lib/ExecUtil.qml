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
	function exec(cmd) {
		connectSource(cmd)
	}
	signal exited(string command, int exitCode, int exitStatus, string stdout, string stderr)

	function trimOutput(stdout) {
		return stdout.replace('\n', ' ').trim()
	}
}
