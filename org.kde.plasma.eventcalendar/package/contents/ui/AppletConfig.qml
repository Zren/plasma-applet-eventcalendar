import QtQuick 2.0

Item {
	id: config

	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	property bool showIconOutline: plasmoid.configuration.show_outlines

	property color meteogramTextColor: plasmoid.configuration.meteogram_textColor || theme.textColor
	property color meteogramScaleColor: plasmoid.configuration.meteogram_gridColor || theme.buttonBackgroundColor
	property color meteogramLabelColor: theme.textColor
	property color meteogramPrecipitationColor: setAlpha("#acd", 0.6)
	property color meteogramPrecipitationTextColor: Qt.tint(theme.textColor, setAlpha("#acd", 0.3))
	property color meteogramPrecipitationTextOutlineColor: showIconOutline ? theme.backgroundColor : "transparent"
	property color meteogramPositiveTempColor: plasmoid.configuration.meteogram_positiveTempColor || "#900"
	property color meteogramNegativeTempColor: plasmoid.configuration.meteogram_negativeTempColor || "#369"

	property color agendaInProgressColor: plasmoid.configuration.agenda_inProgressColor || theme.highlightColor

	property int agendaColumnSpacing: 10 * units.devicePixelRatio
	property int agendaRowSpacing: 10 * units.devicePixelRatio
	property int agendaWeatherColumnWidth: 60 * units.devicePixelRatio
	property int agendaDateColumnWidth: 50 * units.devicePixelRatio + agendaColumnSpacing * 2
	property int eventIndicatorWidth: 2 * units.devicePixelRatio

	property int timerClockFontHeight: 40 * units.devicePixelRatio
	property int timerButtonWidth: 48 * units.devicePixelRatio
}
