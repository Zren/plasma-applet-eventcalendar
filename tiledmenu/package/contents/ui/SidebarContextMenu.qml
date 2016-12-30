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
	width: config.sidebarOpenWidth
	height: childrenRect.height
	z: 2

	default property alias _contentChildren: content.data
	property alias model: repeater.model

	Column {
		id: content
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

		// We're using Column instead of ColumnLayout, so this isn't needed.
		// Keeping it here in case Layout is used in the future.

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		// Component.onDestruction: {
		// 	while (children.length > 0) {
		// 		children[children.length - 1].parent = page;
		// 	}
		// }
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
