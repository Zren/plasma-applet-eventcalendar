import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.private.kicker 0.1 as Kicker

import ".."

RowLayout {
	id: configColor
	spacing: 2
	// Layout.fillWidth: true

	property alias label: label.text

	property string configKey: ''
	property string value: configKey ? plasmoid.configuration[configKey] : "#000"
	onValueChanged: {
		if (!dialog.focus) {
			dialog.color = configColor.value
		}
		if (!textField.activeFocus) {
			textField.text = configColor.value
		}
		if (configKey) {
			plasmoid.configuration[configKey] = value
		}
	}


	Label {
		id: label
		text: "Label"
		Layout.fillWidth: true
	}

	MouseArea {
		// width: label.font.pixelSize
		// height: label.font.pixelSize
		width: textField.height
		height: textField.height
		hoverEnabled: true

		onClicked: dialog.open()

		Rectangle {
			anchors.fill: parent
			color: configColor.value
			border.width: 2
			border.color: parent.containsMouse ? theme.highlightColor : "#BB000000"
		}
	}

	TextField {
		id: textField
		placeholderText: "#AARRGGBB"
		onTextChanged: {
			// Make sure the text is #123 or #112233 or #11223344 before applying the color.
			if (text.indexOf('#') === 0 && (text.length == 4 || text.length == 7 || text.length == 9)) {
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
		onCurrentColorChanged: {
			configColor.value = currentColor
		}
	}
}
