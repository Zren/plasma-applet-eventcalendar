// Version 4

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

/*
** Example:
**
ConfigRadioButtonGroup {
	configKey: "appDescription"
	model: [
		{ value: "a", text: i18n("A") },
		{ value: "b", text: i18n("B") },
		{ value: "c", text: i18n("C") },
	]
}
*/

RowLayout {
	id: configRadioButtonGroup
	Layout.fillWidth: true
	default property alias _contentChildren: content.data
	property alias label: label.text

	property var exclusiveGroup: ExclusiveGroup { id: radioButtonGroup }

	property string configKey: ''
	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : ""

	property alias model: buttonRepeater.model

	//---
	Label {
		id: label
		visible: !!text
		Layout.alignment: Qt.AlignTop | Qt.AlignLeft
	}
	ColumnLayout {
		id: content

		Repeater {
			id: buttonRepeater
			RadioButton {
				visible: typeof modelData.visible !== "undefined" ? modelData.visible : true
				enabled: typeof modelData.enabled !== "undefined" ? modelData.enabled : true
				text: modelData.text
				checked: modelData.value === configValue
				exclusiveGroup: radioButtonGroup
				onClicked: {
					focus = true
					if (configKey) {
						plasmoid.configuration[configKey] = modelData.value
					}
				}
			}
		}
	}
}
