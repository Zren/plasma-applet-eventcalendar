import QtQuick 2.0
import QtQuick.Window 2.2

Item {
	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	//--- Sizes
	readonly property int panelIconSize: 24 * units.devicePixelRatio
	readonly property int flatButtonSize: 60 * units.devicePixelRatio
	readonly property int flatButtonIconSize: 30 * units.devicePixelRatio
	readonly property int sidebarWidth: flatButtonSize
	readonly property int sidebarOpenWidth: 200 * units.devicePixelRatio
	readonly property int appListWidth: plasmoid.configuration.appListWidth * units.devicePixelRatio
	readonly property int leftSectionWidth: sidebarWidth + appListWidth

	readonly property int favCellWidth: 60 * units.devicePixelRatio
	readonly property int favCellPushedMargin: 5 * units.devicePixelRatio
	readonly property int favCellPadding: 3 * units.devicePixelRatio
	readonly property int favColWidth: ((favCellWidth + favCellPadding * 2) * 2) // = 132 (Medium Size)
	readonly property int favViewDefaultWidth: (favColWidth * 3) * units.devicePixelRatio
	readonly property int favSmallIconSize: 32 * units.devicePixelRatio
	readonly property int favMediumIconSize: 72 * units.devicePixelRatio
	readonly property int favGridWidth: plasmoid.configuration.favGridWidth * units.devicePixelRatio

	readonly property int searchFieldHeight: 50 * units.devicePixelRatio

	readonly property int popupWidth: {
		if (plasmoid.configuration.fullscreen) {
			return Screen.desktopAvailableWidth
		} else {
			return leftSectionWidth + favGridWidth
		}
	}
	readonly property int popupHeight: {
		if (plasmoid.configuration.fullscreen) {
			return Screen.desktopAvailableHeight
		} else {
			return plasmoid.configuration.popupHeight * units.devicePixelRatio
		}
	}
	
	readonly property int menuItemHeight: plasmoid.configuration.menuItemHeight * units.devicePixelRatio
	
	readonly property int searchFilterRowHeight: {
		if (plasmoid.configuration.appListWidth >= 310) {
			return flatButtonSize // 60px
		} else if (plasmoid.configuration.appListWidth >= 250) {
			return flatButtonSize*3/4 // 45px
		} else {
			return flatButtonSize/2 // 30px
		}
	}

	//--- Colors
	readonly property color defaultTileColor: plasmoid.configuration.defaultTileColor || theme.buttonBackgroundColor
	readonly property color sidebarBackgroundColor: plasmoid.configuration.sidebarBackgroundColor || theme.backgroundColor
	readonly property color menuItemTextColor2: setAlpha(theme.textColor, 0.6)
	readonly property color favHoverOutlineColor: setAlpha(theme.textColor, 0.8)

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
	// App Description Enum (hidden, after, below)
	readonly property bool appDescriptionVisible: plasmoid.configuration.appDescription !== 'hidden'
	readonly property bool appDescriptionBelow: plasmoid.configuration.appDescription == 'below'

	//--- Settings
	// Search
	readonly property bool searchResultsMerged: plasmoid.configuration.searchResultsMerged
	readonly property bool searchResultsCustomSort: plasmoid.configuration.searchResultsCustomSort
	readonly property int searchResultsDirection: plasmoid.configuration.searchResultsReversed ? ListView.BottomToTop : ListView.TopToBottom
	
	//--- Tile Data
	property var tileData: Base64JsonString {
		configKey: 'tileData'
		defaultValue: {
			// "org.kde.dolphin.desktop": {
			// 	"x": "2",
			// 	"y": "0",
			// 	"size": "small",
			// 	"label": "File Manager"
			// }
			"simplescreenrecorder.desktop": {
				"label": "Screen Recorder"
			}
		}
	}
}
