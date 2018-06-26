import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.components 2.0 as PlasmaComponents

ColumnLayout {
	id: timerInputView

	readonly property int totalSeconds: {
		var h = parseInt(hoursTextField.text || "0", 10)
		var m = parseInt(minutesTextField.text || "0", 10)
		var s = parseInt(secondsTextField.text || "0", 10)

		return (h*60*60) + (m*60) + (s)
	}

	function reset() {
		hoursTextField.text = "0"
		minutesTextField.text = "00"
		secondsTextField.text = "00"
	}

	function cancel() {
		timerInputView.reset()
		timerView.setTimerViewVisible = false
	}

	function start() {
		console.log('timerInputView.totalSeconds', timerInputView.totalSeconds)
		timerView.setDurationAndStart(timerInputView.totalSeconds)
		timerView.setTimerViewVisible = false
	}

	RowLayout {
		id: textFieldRow
		Layout.fillHeight: true
		spacing: 0

		property int fontPixelSize: height/2

		TimerTextField {
			id: hoursTextField
			defaultText: "0"
			validator: IntValidator { bottom: 0 }
		}

		PlasmaComponents.Label {
			Layout.fillHeight: true
			font.pointSize: -1
			font.pixelSize: textFieldRow.fontPixelSize
			text: ":"
		}

		TimerTextField {
			id: minutesTextField
		}

		PlasmaComponents.Label {
			Layout.fillHeight: true
			font.pointSize: -1
			font.pixelSize: textFieldRow.fontPixelSize
			text: ":"
		}

		TimerTextField {
			id: secondsTextField
		}
	}

	RowLayout {
		Item {
			Layout.fillWidth: true
		}
		PlasmaComponents.Button {
			text: i18n("Cancel")
			implicitWidth: minimumWidth
			onClicked: timerInputView.cancel()
		}
		PlasmaComponents.Button {
			text: i18n("Start")
			implicitWidth: minimumWidth
			onClicked: timerInputView.start()
		}
	}

	Component.onCompleted: {
		minutesTextField.forceActiveFocus()
	}
}
