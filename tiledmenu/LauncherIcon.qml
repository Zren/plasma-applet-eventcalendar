import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: launcherIcon
	property int iconSize: 32
	property alias iconSource: icon.source
	property alias backgroundColor: background.color
	width: iconSize
	height: iconSize

	Rectangle {
		id: background
		anchors.fill: parent
		color: "transparent"
	}

	PlasmaCore.IconItem {
		id: icon
		anchors.centerIn: parent
		source: "view-calendar"
		width: launcherIcon.iconSize
		height: launcherIcon.iconSize
	}
}