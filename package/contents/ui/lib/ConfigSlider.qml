// Version 2

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configSlider

	property string configKey: ''
	property alias maximumValue: slider.maximumValue
	property alias minimumValue: slider.minimumValue
	property alias stepSize: slider.stepSize
	property alias updateValueWhileDragging: slider.updateValueWhileDragging
	property alias value: slider.value

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Layout.fillWidth: true

	Label {
		id: labelBefore
		text: ""
		visible: text
	}
	
	Slider {
		id: slider
		Layout.fillWidth: configSlider.Layout.fillWidth

		value: plasmoid.configuration[configKey]
		// onValueChanged: plasmoid.configuration[configKey] = value
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
		onTriggered: plasmoid.configuration[configKey] = value
	}
}
