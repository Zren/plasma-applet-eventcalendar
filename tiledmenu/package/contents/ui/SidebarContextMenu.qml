import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

SidebarMenu {
	id: sidebarContextMenu
	visible: open
	open: false
	anchors.left: parent.right
	anchors.bottom: parent.bottom
	width: 200
	height: childrenRect.height
	z: 2

	property alias model: repeater.model

	Rectangle {
		anchors.fill: parent
		color: "#000"
	}

	Column {
		width: parent.width
		height: childrenRect.height
		Repeater {
			id: repeater
			delegate: SidebarItem {
				expanded: true
				labelVisible: true
				iconName: model.iconName
				text: model.name
				onClicked: {
					sidebarContextMenu.open = false
					repeater.model.triggerIndex(index)
				}
				
			}
		}
		
	}

	// onVisibleChanged: {
	// 	if (sidebarContextMenu.visible) {
	// 		sidebarContextMenu.focus = true
	// 	}
	// }

	onFocusChanged: {
		console.log('sidebarContextMenu.onFocusChanged', focus)
		if (!sidebarContextMenu.focus) {
			sidebarContextMenu.open = false
		}
	}

	onActiveFocusChanged: {
		console.log('sidebarContextMenu.onActiveFocusChanged', activeFocus)
		if (!sidebarContextMenu.activeFocus) {
			sidebarContextMenu.open = false
		}
	}
}
