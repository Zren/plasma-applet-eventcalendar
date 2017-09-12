import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "lib"

GroupBox {
	id: tileEditorColorField
	title: "Label"
	implicitWidth: parent.implicitWidth
	Layout.fillWidth: true
	property alias placeholderText: textField.placeholderText
	property alias enabled: textField.enabled
	property string key: ''

	style: GroupBoxStyle {}

	RowLayout {
		anchors.fill: parent

		MouseArea {
			id: mouseArea
			width: textField.height
			height: textField.height
			hoverEnabled: true

			onClicked: dialog.open()

			Rectangle {
				anchors.fill: parent
				color: textField.text
				border.width: 3
				border.color: mouseArea.containsMouse ? theme.highlightColor : theme.backgroundColor

				Rectangle {
					anchors.fill: parent
					anchors.margins: 1
					color: "transparent"
					border.width: 1
					border.color: mouseArea.containsMouse ? theme.highlightColor : theme.textColor
				}
			}

			ColorDialog {
				id: dialog
				visible: false
				// modality: Qt.WindowModal // Don't dim the menu
				title: tileEditorColorField.title
				showAlphaChannel: true
				color: textField.text
				onCurrentColorChanged: {
					if (visible && color != currentColor) {
						textField.text = currentColor
					}
				}
			}
		}

		PlasmaComponents.TextField {
			id: textField
			Layout.fillWidth: true
			text: key && appObj.tile ? appObj.tile[key] : ''
			property bool updateOnChange: false
			onTextChanged: {
				if (key && updateOnChange) {
					if (text) {
						appObj.tile[key] = text
					} else {
						delete appObj.tile[key]
					}
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
