import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

// See: /usr/lib/x86_64-linux-gnu/qt5/qml/QtQuick/Controls/Styles/Plasma/CheckBoxStyle.qml
MouseArea {
	id: control
	hoverEnabled: true
	opacity: control.enabled ? 1 : 0.6

	property bool checked: true
	readonly property int checkedState: {
		if (checked) {
			if (pressed && containsMouse) {
				return 0
			} else {
				return Qt.Checked
			}
		} else {
			if (pressed && containsMouse) {
				return Qt.Checked
			} else {
				return 0
			}
		}
	}
	onCheckedChanged: console.log('checked', checked)
	onCheckedStateChanged: console.log('checkedState', checkedState)
	onPressedChanged: console.log('pressed', pressed)

	onClicked: checked = !checked

	function alpha(c, a) {
		return Qt.rgba(c.r, c.g, c.b, a)
	}

	property int borderRadius: 3 * units.devicePixelRatio
	Rectangle {
		anchors.fill: parent
		anchors.margins: Math.round(3 * units.devicePixelRatio)
		color: theme.buttonBackgroundColor
		border.width: Math.max(1, Math.round(1 * units.devicePixelRatio))
		radius: control.borderRadius
		border.color: control.containsMouse ? theme.highlightColor : alpha(theme.buttonTextColor, 0.3)

		Item {
			anchors.fill: parent
			visible: opacity > 0
			opacity: {
				switch (control.checkedState) {
				case Qt.Checked:
					return 1
				case Qt.PartiallyChecked:
					return 0.5
				default:
					return 0
				}
			}
			Behavior on opacity {
				NumberAnimation {
					duration: units.longDuration
					easing.type: Easing.InOutQuad
				}
			}

			Rectangle {
				anchors.fill: parent
				anchors.margins: 1
				radius: control.borderRadius
				border.color: alpha(theme.highlightColor, 0.5)
				border.width: 1
				color: "transparent"

				Rectangle {
					anchors.fill: parent
					anchors.margins: 2
					radius: control.borderRadius
					border.color: alpha(theme.highlightColor, 0.5)
					border.width: 1
					color: theme.highlightColor
				}
			}
		}
	}

}
