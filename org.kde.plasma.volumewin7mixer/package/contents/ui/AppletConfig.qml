import QtQuick 2.0

QtObject {
	property int mediaControllerSliderHeight: 16 * units.devicePixelRatio
	// property int mediaControllerButtonHeight: 48 * units.devicePixelRatio
	property int mediaControllerHeight: 64 * units.devicePixelRatio
	property int mixerGroupHeight: units.gridUnit * 24
	property int mixerItemWidth: 100 * units.devicePixelRatio
	property int volumeSliderWidth: 48 * units.devicePixelRatio

	property string volumeSliderDesktopThemeId: "widgets/volumeslider"
	property string volumeSliderUrl: {
		if (plasmoid.configuration.volumeSliderTheme == "desktoptheme") {
			if (false) { // svg exists
				return volumeSliderDesktopThemeId
			} else {
				return plasmoid.file("images", "volumeslider.svg") // colortheme
			}
		} else if (plasmoid.configuration.volumeSliderTheme == "colortheme") {
			return plasmoid.file("images", "volumeslider.svg")
		} else { // default
			return plasmoid.file("images", "volumeslider-default.svg")
		}
	}
}
