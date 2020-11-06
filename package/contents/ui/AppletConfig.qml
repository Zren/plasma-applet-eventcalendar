import QtQuick 2.0

import "lib"

QtObject {
	id: config

	function setAlpha(c, a) {
		var c2 = Qt.darker(c, 1)
		c2.a = a
		return c2
	}

	property bool showIconOutline: plasmoid.configuration.showOutlines

	property color meteogramTextColorDefault: theme.textColor
	property color meteogramScaleColorDefault: theme.buttonBackgroundColor
	property color meteogramPrecipitationRawColorDefault: "#acd"
	property color meteogramPositiveTempColorDefault: "#900"
	property color meteogramNegativeTempColorDefault: "#369"
	property color meteogramIconColorDefault: theme.textColor

	property color meteogramTextColor: plasmoid.configuration.meteogram_textColor || meteogramTextColorDefault
	property color meteogramScaleColor: plasmoid.configuration.meteogram_gridColor || meteogramScaleColorDefault
	property color meteogramPrecipitationRawColor: plasmoid.configuration.meteogram_rainColor || meteogramPrecipitationRawColorDefault
	property color meteogramPrecipitationColor: setAlpha(meteogramPrecipitationRawColor, 0.6)
	property color meteogramPrecipitationTextColor: Qt.tint(meteogramTextColor, setAlpha(meteogramPrecipitationRawColor, 0.3))
	property color meteogramPrecipitationTextOutlineColor: showIconOutline ? theme.backgroundColor : "transparent"
	property color meteogramPositiveTempColor: plasmoid.configuration.meteogram_positiveTempColor || meteogramPositiveTempColorDefault
	property color meteogramNegativeTempColor: plasmoid.configuration.meteogram_negativeTempColor || meteogramNegativeTempColorDefault
	property color meteogramIconColor: plasmoid.configuration.meteogram_iconColor || meteogramIconColorDefault

	property color agendaInProgressColorDefault: theme.highlightColor
	property color agendaInProgressColor: plasmoid.configuration.agendaInProgressColor || agendaInProgressColorDefault

	property int agendaColumnSpacing: 10 * units.devicePixelRatio
	property int agendaDaySpacing: plasmoid.configuration.agendaDaySpacing * units.devicePixelRatio
	property int agendaEventSpacing: plasmoid.configuration.agendaEventSpacing * units.devicePixelRatio
	property int agendaWeatherColumnWidth: 60 * units.devicePixelRatio
	property int agendaWeatherIconSize: plasmoid.configuration.agendaWeatherIconHeight * units.devicePixelRatio
	property int agendaDateColumnWidth: 50 * units.devicePixelRatio + agendaColumnSpacing * 2
	property int eventIndicatorWidth: 2 * units.devicePixelRatio

	property int agendaFontSize:  plasmoid.configuration.agendaFontSize == 0 ? theme.defaultFont.pixelSize : plasmoid.configuration.agendaFontSize * units.devicePixelRatio

	property int timerClockFontHeight: 40 * units.devicePixelRatio
	property int timerButtonWidth: 48 * units.devicePixelRatio

	property int meteogramIconSize: 24 * units.devicePixelRatio
	property int meteogramColumnWidth: 32 * units.devicePixelRatio // weatherIconSize = 32px (height = 24px but most icons are landscape)

	property QtObject icalCalendarList: Base64Json {
		configKey: 'icalCalendarList'
	}

	property ListModel icalCalendarListModel: Base64JsonListModel {
		configKey: 'icalCalendarList'
	}

	readonly property string localeTimeFormat: Qt.locale().timeFormat(Locale.ShortFormat)
	readonly property string localeDateFormat: Qt.locale().dateFormat(Locale.ShortFormat)
	readonly property string line1TimeFormat: plasmoid.configuration.clockTimeFormat || localeTimeFormat
	readonly property string line2TimeFormat: plasmoid.configuration.clockTimeFormat2 || localeDateFormat
	readonly property string combinedFormat: {
		if (plasmoid.configuration.clockline2) {
			return line1TimeFormat + '\n' + line2TimeFormat
		} else {
			return line1TimeFormat
		}
	}
	readonly property bool clock24h: {
		var is12hour = combinedFormat.toLowerCase().indexOf('ap') >= 0
		return !is12hour
	}
}
