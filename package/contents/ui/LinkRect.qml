import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib"

Rectangle {
	id: linkRect
	width: implicitWidth
	height: implicitHeight
	implicitWidth: childrenRect.width
	implicitHeight: childrenRect.height
	property color backgroundColor: "transparent"
	property color backgroundHoverColor: appletConfig.agendaHoverBackground
	color: enabled && hovered ? backgroundHoverColor : backgroundColor
	property string tooltipMainText
	property string tooltipSubText
	property alias acceptedButtons: mouseArea.acceptedButtons
	property bool enabled: true
	readonly property alias hovered: mouseArea.containsMouse

	signal clicked(var mouse)
	signal leftClicked(var mouse)
	signal doubleClicked(var mouse)
	signal loadContextMenu(var contextMenu)
	
	PlasmaCore.ToolTipArea {
		id: tooltip
		anchors.fill: parent
		mainText: linkRect.tooltipMainText
		subText: linkRect.tooltipSubText

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			acceptedButtons: Qt.LeftButton | Qt.RightButton
			cursorShape: linkRect.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
			enabled: linkRect.enabled
			onClicked: {
				mouse.accepted = false
				linkRect.clicked(mouse)
				if (!mouse.accepted) {
					if (mouse.button == Qt.LeftButton) {
						linkRect.leftClicked(mouse)
					} else if (mouse.button == Qt.RightButton) {
						contextMenu.show(mouse.x, mouse.y)
						mouse.accepted = true
					}
				}
			}
			onDoubleClicked: linkRect.doubleClicked(mouse)
		}
	}

	ContextMenu {
		id: contextMenu
		onPopulate: linkRect.loadContextMenu(contextMenu)
	}
}
