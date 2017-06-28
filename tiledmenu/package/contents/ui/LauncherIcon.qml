import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.draganddrop 2.0 as DragAndDrop

MouseArea {
	id: launcherIcon

	readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
		|| plasmoid.location == PlasmaCore.Types.RightEdge
		|| plasmoid.location == PlasmaCore.Types.BottomEdge
		|| plasmoid.location == PlasmaCore.Types.LeftEdge)

	Layout.minimumWidth: {
		switch (plasmoid.formFactor) {
		case PlasmaCore.Types.Vertical:
			return 0;
		case PlasmaCore.Types.Horizontal:
			return height;
		default:
			return units.gridUnit * 3;
		}
	}

	Layout.minimumHeight: {
		switch (plasmoid.formFactor) {
		case PlasmaCore.Types.Vertical:
			return width;
		case PlasmaCore.Types.Horizontal:
			return 0;
		default:
			return units.gridUnit * 3;
		}
	}

	Layout.maximumWidth: inPanel ? units.iconSizeHints.panel : -1
	Layout.maximumHeight: inPanel ? units.iconSizeHints.panel : -1


	property int iconSize: Math.min(width, height)
	property alias iconSource: icon.source

	PlasmaCore.IconItem {
		id: icon
		anchors.centerIn: parent
		source: "start-here-kde"
		width: launcherIcon.iconSize
		height: launcherIcon.iconSize
		active: launcherIcon.containsMouse
	}
	
	// Debugging
	// Rectangle { anchors.fill: parent; border.color: "#ff0"; color: "transparent"; border.width: 1; }
	// Rectangle { anchors.fill: icon; border.color: "#f00"; color: "transparent"; border.width: 1; }


	hoverEnabled: true
	// cursorShape: Qt.PointingHandCursor

	onClicked: {
		plasmoid.expanded = !plasmoid.expanded
	}

	property alias activateOnDrag: dropArea.enabled
	DragAndDrop.DropArea {
		id: dropArea
		anchors.fill: parent

		onDragEnter: {
			dragHoverTimer.restart()
		}
	}

	onContainsMouseChanged: {
		if (!containsMouse) {
			dragHoverTimer.stop()
		}
	}

	Timer {
		id: dragHoverTimer
		interval: 250 // Same as taskmanager's activationTimer in MouseHandler.qml
		onTriggered: plasmoid.expanded = true
	}
}
