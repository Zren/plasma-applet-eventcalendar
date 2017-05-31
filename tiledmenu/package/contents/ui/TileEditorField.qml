import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

GroupBox {
	title: "Label"
	Layout.fillWidth: true
	property alias placeholderText: textField.placeholderText
	property alias enabled: textField.enabled
	property string key: ''

	ColumnLayout {
		anchors.fill: parent

		PlasmaComponents.TextField {
			id: textField
			Layout.fillWidth: true
			text: key && appObj.tile ? appObj.tile[key] : ''
			property bool updateOnChange: false
			onTextChanged: {
				if (key && updateOnChange) {
					appObj.tile[key] = text
					appObj.tileChanged()
					favouritesView.tileModelChanged()
				}
			}

			Connections {
				target: appObj

				onTileChanged: {
					if (key && tile) {
						textField.updateOnChange = false
						textField.text = appObj.tile[key] || ''
						textField.updateOnChange = true
					}
				}
			}
		}
	}
}
