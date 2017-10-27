import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import ".."

TextField {
	id: configString
	Layout.fillWidth: true

	property string configKey: ''
	property alias value: configString.text
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!configString.focus && value != configValue) {
			value = configValue
		}
	}
	property string defaultValue: ""

	text: configString.configValue
	onTextChanged: serializeTimer.restart()

	ToolButton {
		iconName: "edit-clear"
		onClicked: configString.value = defaultValue

		anchors.top: parent.top
		anchors.right: parent.right
		anchors.bottom: parent.bottom

		width: height
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: plasmoid.configuration[configKey] = configString.value
	}
}
