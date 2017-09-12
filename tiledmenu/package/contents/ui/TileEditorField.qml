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
	id: tileEditorField
	title: "Label"
	implicitWidth: parent.implicitWidth
	Layout.fillWidth: true
	property alias text: textField.text
	property alias placeholderText: textField.placeholderText
	property alias enabled: textField.enabled
	property string key: ''
	property string checkedKey: ''
	checkable: checkedKey
	property bool checkedDefault: true
	property Item itemAfter: null

	property bool updateOnChange: false
	onCheckedChanged: {
		if (checkedKey && tileEditorField.updateOnChange) {
			appObj.tile[checkedKey] = checked
			appObj.tileChanged()
			favouritesView.tileModelChanged()
		}
	}

	default property alias _contentChildren: content.data

	Connections {
		target: appObj

		onTileChanged: {
			if (checkedKey && tile) {
				tileEditorField.updateOnChange = false
				tileEditorField.checked = typeof appObj.tile[checkedKey] !== "undefined" ? appObj.tile[checkedKey] : checkedDefault
				tileEditorField.updateOnChange = true
			}
		}
	}

	style: GroupBoxStyle {}

	RowLayout {
		id: content
		anchors.fill: parent

		PlasmaComponents.TextField {
			id: textField
			Layout.fillWidth: true
			text: key && appObj.tile && appObj.tile[key] ? appObj.tile[key] : ''
			property bool updateOnChange: false
			onTextChanged: {
				if (key && textField.updateOnChange) {
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

		Component.onDestruction: {
			while (children.length > 0) {
				children[children.length - 1].parent = tileEditorField
			}
		}
	}
}
