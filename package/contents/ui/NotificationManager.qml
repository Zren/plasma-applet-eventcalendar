import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "./lib"

QtObject {
	id: notificationManager

	property var dataSource: PlasmaCore.DataSource {
		id: dataSource
		engine: "notifications"
		connectedSources: "org.freedesktop.Notifications"
	}

	function createNotification(args) {
		// https://github.com/KDE/plasma-workspace/blob/master/dataengines/notifications/notifications.operations
		var service = dataSource.serviceForSource("notification")
		var operation = service.operationDescription("createNotification")

		operation.appName = args.appName || "plasmashell"
		operation.appIcon = args.appIcon || ""
		operation.summary = args.summary || ""
		operation.body = args.body || ""
		if (typeof args.expireTimeout !== "undefined") {
			operation.expireTimeout = args.expireTimeout
		}

		service.startOperationCall(operation)
		if (sfx && args.soundFile) {
			sfx.source = args.soundFile
			sfx.play()
		}
	}

	property var sfx: Qt.createQmlObject("import QtMultimedia 5.4; Audio {}", notificationManager)

	property var executable: ExecUtil { id: executable }

	function notify(args, callback) {
		logger.debugJSON('NotificationMananger.notify', args)
		args.sound = args.sound || args.soundFile

		var cmd = [
			'python3',
			plasmoid.file("", "scripts/notification.py"),
		]		
		if (args.appName) {
			cmd.push('--app-name', args.appName)
		}
		if (args.appIcon) {
			cmd.push('--icon', args.appIcon)
		}
		if (args.sound) {
			cmd.push('--sound', args.sound)
			if (args.loop) {
				cmd.push('--loop', args.loop)
			}
		}
		if (args.actions) {
			for (var i = 0; i < args.actions.length; i++) {
				var action = args.actions[i]
				cmd.push('--action', action)
			}
		}
		cmd.push('--metadata', '' + Date.now())
		cmd.push(args.summary)
		cmd.push(args.body)
		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			var actionId = stdout.replace('\n', ' ').trim()
			callback(actionId)
		})
	}
}
