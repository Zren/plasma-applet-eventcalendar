import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
	hoverEnabled: true
	z: 1
	// clip: true
	width: open ? config.sidebarOpenWidth : config.sidebarWidth
	property bool open: false

	onOpenChanged: {
		if (open) {
			forceActiveFocus()
		}
	}

	Rectangle {
		anchors.fill: parent
		color: config.sidebarBackgroundColor
		opacity: parent.open ? 1 : 0.5
	}

	// Rectangle {
	// 	anchors.fill: parent
	// 	color: theme.backgroundColor
	// 	opacity: sidebarContextMenu.open ? 1 : 0
	// }
	// PlasmaCore.FrameSvgItem {
	// 	anchors.fill: parent
	// 	imagePath: "widgets/frame"
	// 	prefix: "plain"
	// }
}
