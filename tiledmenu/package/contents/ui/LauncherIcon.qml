import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

MouseArea {
	id: launcherIcon
	property int iconSize: 32
	property alias iconSource: icon.source
	// property alias backgroundColor: background.color
	width: iconSize
	height: iconSize
	hoverEnabled: true
	// cursorShape: Qt.PointingHandCursor

	// Rectangle {
	// 	id: background
	// 	anchors.fill: parent
	// 	color: "transparent"
	// }

	PlasmaCore.IconItem {
		id: icon
		anchors.centerIn: parent
		source: "view-calendar"
		width: launcherIcon.iconSize
		height: launcherIcon.iconSize
		active: launcherIcon.containsMouse
	}

	// states: [
	// 	State {
	// 		name: "hovering"
	// 		when: !launcherIcon.pressed && launcherIcon.containsMouse
	// 		PropertyChanges {
	// 			target: background
	// 			color: theme.buttonBackgroundColor
	// 		}
	// 	},
	// 	State {
	// 		name: "pressed"
	// 		when: launcherIcon.pressed
	// 		PropertyChanges {
	// 			target: background
	// 			color: theme.highlightColor
	// 		}
	// 	}
	// ]

	// transitions: [
	// 	Transition {
	// 		to: "hovering"
	// 		ColorAnimation { duration: 200 }
	// 	},
	// 	Transition {
	// 		to: "pressed"
	// 		ColorAnimation { duration: 100 }
	// 	}
	// ]
}
