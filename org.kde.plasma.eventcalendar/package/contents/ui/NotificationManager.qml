import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import QtMultimedia 5.4

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
		if (args.soundFile) {
			sfx.source = args.soundFile
			sfx.play()
		}
	}

	property Audio sfx: Audio {}
}
