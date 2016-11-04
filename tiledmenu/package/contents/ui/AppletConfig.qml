import QtQuick 2.0

Item {
	// Colors
	readonly property color defaultTileColor: plasmoid.configuration.defaultTileColor || theme.buttonBackgroundColor
	readonly property color sidebarBackgoundColor: plasmoid.configuration.sidebarBackgoundColor || "#000"
}
