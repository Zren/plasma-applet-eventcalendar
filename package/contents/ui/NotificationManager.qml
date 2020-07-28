import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "./lib"

QtObject {
	id: notificationManager

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
		var sanitizedSummary = executable.sanitizeString(args.summary)
		var sanitizedBody = executable.sanitizeString(args.body)
		cmd.push(sanitizedSummary)
		cmd.push(sanitizedBody)
		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			var actionId = stdout.replace('\n', ' ').trim()
			if (typeof callback === 'function') {
				callback(actionId)
			}
		})
	}
}
