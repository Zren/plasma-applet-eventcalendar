// Version 3

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configSpinBox

	property string configKey: ''
	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : 0
	property alias decimals: spinBox.decimals
	property alias horizontalAlignment: spinBox.horizontalAlignment
	property alias maximumValue: spinBox.maximumValue
	property alias minimumValue: spinBox.minimumValue
	property alias prefix: spinBox.prefix
	property alias stepSize: spinBox.stepSize
	property alias suffix: spinBox.suffix
	property alias value: spinBox.value

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}
	
	SpinBox {
		id: spinBox

		value: configValue
		onValueChanged: serializeTimer.start()
		maximumValue: 2147483647
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: {
			if (configKey) {
				plasmoid.configuration[configKey] = value
			}
		}
	}
}
