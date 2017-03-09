import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

Item {
	id: page

	SinkModel { id: sinkModel }
	StreamRestoreModel { id: streamRestoreModel }

	TableView {
		anchors.fill: parent

		model: streamRestoreModel

		TableViewColumn {
			role: "Name"
			title: "Name"
		}

		TableViewColumn {
			role: "Device"
			title: "Device"
		}
	}
}
