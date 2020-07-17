// Version 5

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2
import org.kde.kirigami 2.0 as Kirigami

import ".."

RowLayout {
	id: configColor
	spacing: 2
	// Layout.fillWidth: true
	Layout.maximumWidth: 300 * Kirigami.Units.devicePixelRatio

	property alias label: label.text
	property alias labelColor: label.color
	property alias horizontalAlignment: label.horizontalAlignment
	property alias showAlphaChannel: dialog.showAlphaChannel
	property color buttonOutlineColor: {
		if (valueColor.r + valueColor.g + valueColor.b > 0.5) {
			return "#BB000000" // Black outline
		} else {
			return "#BBFFFFFF" // White outline
		}
	}

	property TextField textField: textField
	property ColorDialog dialog: dialog

	property string configKey: ''
	property string defaultColor: ''
	property string value: {
		if (configKey) {
			return plasmoid.configuration[configKey]
		} else {
			return "#000"
		}
	}

	readonly property color defaultColorValue: defaultColor
	readonly property color valueColor: {
		if (value == '' && defaultColor) {
			return defaultColor
		} else {
			return value
		}
	}

	onValueChanged: {
		if (!textField.activeFocus) {
			textField.text = configColor.value
		}
		if (configKey) {
			if (value == defaultColorValue) {
				plasmoid.configuration[configKey] = ""
			} else {
				plasmoid.configuration[configKey] = value
			}
		}
	}

	function setValue(newColor) {
		textField.text = newColor
	}

	Label {
		id: label
		text: "Label"
		Layout.fillWidth: horizontalAlignment == Text.AlignRight
		horizontalAlignment: Text.AlignLeft
	}

	MouseArea {
		id: mouseArea
		Layout.preferredWidth: textField.height
		Layout.preferredHeight: textField.height
		hoverEnabled: true

		onClicked: dialog.open()

		Rectangle {
			anchors.fill: parent
			color: configColor.valueColor
			border.width: 2
			border.color: parent.containsMouse ? Kirigami.Theme.highlightColor : buttonOutlineColor
		}
	}

	TextField {
		id: textField
		placeholderText: defaultColor ? defaultColor : "#AARRGGBB"
		Layout.fillWidth: label.horizontalAlignment == Text.AlignLeft
		onTextChanged: {
			// Make sure the text is:
			//   Empty (use default)
			//   or #123 or #112233 or #11223344 before applying the color.
			if (text.length === 0
				|| (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9))
			) {
				configColor.value = text
			}
		}
	}

	ColorDialog {
		id: dialog
		visible: false
		modality: Qt.WindowModal
		title: configColor.label
		showAlphaChannel: true
		color: configColor.valueColor
		onCurrentColorChanged: {
			if (visible && color != currentColor) {
				configColor.value = currentColor
			}
		}
	}
}
