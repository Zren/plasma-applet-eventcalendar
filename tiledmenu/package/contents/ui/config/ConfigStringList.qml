import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configStringList
	Layout.fillWidth: true
	// implicitHeight: textArea.implicitHeight
	// Layout.preferredHeight: textArea.Layout.preferredHeight

	property string configKey: ''

	property alias enabled: textArea.enabled

	readonly property var configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: deserialize()
	readonly property var value: parseStringList(configValue)

	function parseStringList(stringList) {
		return stringList.toString().split(",")
	}
	function parseValue(value) {
		return value.join("\n")
	}
	function parseText(text) {
		return text.split("\n")
	}

	function setValue(val) {
		var newText = parseValue(val)
		if (textArea.text != newText) {
			textArea.text = newText
		}
	}

	function deserialize() {
		// console.log('deserialize', configValue)
		if (!textArea.focus) {
			setValue(value)
		}
	}
	function serialize() {
		var newValue = parseText(textArea.text)
		// console.log('serialize', configKey, newValue)
		if (plasmoid.configuration[configKey] != newValue) {
			plasmoid.configuration[configKey] = newValue
		}
	}

	property alias before: labelBefore.text
	property alias after: labelAfter.text

	Label {
		id: labelBefore
		text: ""
		visible: text
	}
	
	TextArea {
		id: textArea
		Layout.fillWidth: true
		// implicitHeight: font.pixelSize * (lineCount + 2)
		// Layout.minimumHeight: implicitHeight
		// Layout.preferredHeight: implicitHeight
		// Layout.maximumHeight: implicitHeight

		// text: parseValue(configStringList.value)
		onTextChanged: serializeTimer.restart()
		// onFocusChanged: console.log('textArea.focus', focus)
	}

	Label {
		id: labelAfter
		text: ""
		visible: text
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: serialize()
	}
}
