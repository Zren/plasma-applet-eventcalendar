import QtQuick 2.0

Item {
	id: config

	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	property bool showIconOutline: plasmoid.configuration.show_outlines

	property color meteogramScaleColor: theme.buttonBackgroundColor
	property color meteogramLabelColor: theme.textColor
	property color meteogramPrecipitationColor: setAlpha("#acd", 0.6)
	property color meteogramPrecipitationTextColor: Qt.tint(theme.textColor, setAlpha("#acd", 0.3))
	property color meteogramPrecipitationTextOutlineColor: showIconOutline ? theme.backgroundColor : "transparent"
	property color meteogramTempAbove0Color: "#900"
	property color meteogramTempBelow0Color: "#369"

	property int agendaWeatherColumnWidth: 60 * units.devicePixelRatio
	property int agendaDateColumnWidth: 50 * units.devicePixelRatio

	property int timerClockFontHeight: 40 * units.devicePixelRatio
	property int timerButtonWidth: 48 * units.devicePixelRatio
}
