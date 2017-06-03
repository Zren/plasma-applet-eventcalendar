import QtQuick 2.0

Item {
	id: batteryIcon
	// Copy of the Breeze icon.

	// width: size
	// height: size * 3/5
	// property int size: 20 // 20

	// width: 30

	property bool charging: false
	property int charge: 0
	property color normalColor: theme.textColor
	property color chargingColor: "#1e1"
	property color lowBatteryColor: "#e33"
	property int lowBatteryPercent: 20

	Rectangle {
		// Outline
		anchors.fill: parent
		anchors.rightMargin: 1
		color: "transparent"
		border.color: normalColor

		Item {
			anchors.fill: parent
			anchors.margins: 2

			Rectangle {
				// Charged % Fill
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				color: {
					if (charging) {
						return chargingColor
					} else if (charge < lowBatteryPercent) {
						return lowBatteryColor
					} else {
						return normalColor
					}
				}
				width: parent.width * Math.max(0, Math.min(charge, 100)) / 100
			}
		}
	}
	Rectangle {
		// Bump
		anchors.right: parent.right
		anchors.verticalCenter: parent.verticalCenter
		height: parent.height / 3
		width: 1
		color: normalColor
	}
}
