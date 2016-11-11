import QtQuick 2.0

Item {
	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	//--- Colors
	readonly property color defaultTileColor: plasmoid.configuration.defaultTileColor || theme.buttonBackgroundColor
	readonly property color sidebarBackgroundColor: plasmoid.configuration.sidebarBackgroundColor || '#000'
	readonly property color menuItemTextColor2: setAlpha(theme.textColor, 0.6)

	//--- Style
	// Tiles
	readonly property int tileLabelAlignment: {
		var val = plasmoid.configuration.tileLabelAlignment
		if (val === 'center') {
			return Text.AlignHCenter
		} else if (val === 'right') {
			return Text.AlignRight
		} else { // left
			return Text.AlignLeft
		}
	}
	
}
