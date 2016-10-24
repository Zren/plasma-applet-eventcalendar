import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ToolButton {
	id: menuListItem
	Layout.fillWidth: true
	height: 32
	property alias iconSource: launcherIcon.iconSource
	property alias iconBackgroundColor: launcherIcon.backgroundColor
	property bool circleIcon: false
	property alias description: label.text
	property alias showHasChildrenArrow: hasChildrenArrow.visible

	Rectangle {
		anchors.fill: parent
		visible: false
		color: "#111"
		opacity: 0.6
		border.width: menuListItem.circleIcon ? width/2 : 0
	}

	RowLayout {
		anchors.fill: parent
		visible: false

		LauncherIcon {
			id: launcherIcon
			iconSource: "view-calendar"
			iconSize: menuListItem.height
		}

		PlasmaComponents.Label {
			id: label
			text: "Description"
			Layout.fillWidth: true
		}

		PlasmaCore.IconItem {
			id: hasChildrenArrow
			visible: false
			source: 'arrow-right'
			height: menuListItem.height
		}
	}
}