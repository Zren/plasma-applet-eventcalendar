import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

SpinBox {
	id: spinBox
	property string key: ''
	Layout.fillWidth: true
	implicitWidth: 20
	Layout.minimumWidth: 20
	value: appObj.tile && appObj.tile[key] || 0
	property bool updateOnChange: false
	onValueChanged: {
		if (key && updateOnChange) {
			appObj.tile[key] = value
			appObj.tileChanged()
			favouritesView.tileModelChanged()
		}
	}

	Connections {
		target: appObj

		onTileChanged: {
			if (key && tile) {
				spinBox.updateOnChange = false
				spinBox.value = appObj.tile[key] || 0
				spinBox.updateOnChange = true
			}
		}
	}
}
