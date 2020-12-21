import QtQuick 2.0

import "./calendars/PlasmaCalendarUtils.js" as PlasmaCalendarUtils

QtObject {
	signal migrate()

	function copy(oldKey, newKey) {
		if (typeof plasmoid.configuration[oldKey] === 'undefined') return
		if (typeof plasmoid.configuration[newKey] === 'undefined') return
		if (plasmoid.configuration[oldKey] === plasmoid.configuration[newKey]) return
		plasmoid.configuration[newKey] = plasmoid.configuration[oldKey]
		console.log('[eventcalendar:migrate] copy ' + oldKey + ' => ' + newKey + ' (value: ' + plasmoid.configuration[oldKey] + ')')
	}

	Component.onCompleted: migrate()
	onMigrate: {
		// Modified in: v72
		if (!plasmoid.configuration.v72Migration) {
			var oldValue = plasmoid.configuration.enabledCalendarPlugins
			var newValue = PlasmaCalendarUtils.pluginPathToFilenameList(plasmoid.configuration.enabledCalendarPlugins)
			plasmoid.configuration.enabledCalendarPlugins = newValue
			console.log('[eventcalendar:migrate] convert enabledCalendarPlugins (' + oldValue + ' => ' + newValue + ')')

			plasmoid.configuration.v72Migration = true
		}

		// Renamed in: v71
		if (!plasmoid.configuration.v71Migration) {
			copy('widget_show_meteogram', 'widgetShowMeteogram')
			copy('widget_show_timer', 'widgetShowTimer')
			copy('widget_show_agenda', 'widgetShowAgenda')
			copy('widget_show_calendar', 'widgetShowCalendar')
			copy('timer_sfx_enabled', 'timerSfxEnabled')
			copy('timer_sfx_filepath', 'timerSfxFilepath')
			copy('timer_repeats', 'timerRepeats')
			copy('clock_fontfamily', 'clockFontFamily')
			copy('clock_timeformat', 'clockTimeFormat1')
			copy('clock_timeformat_2', 'clockTimeFormat2')
			copy('clock_line_2', 'clockShowLine2')
			copy('clock_line_2_height_ratio', 'clockLine2HeightRatio')
			copy('clock_line_1_bold', 'clockLineBold1')
			copy('clock_line_2_bold', 'clockLineBold2')
			copy('clock_maxheight', 'clockMaxHeight')
			copy('clock_mousewheel_up', 'clockMouseWheelUp')
			copy('clock_mousewheel_down', 'clockMouseWheelDown')
			copy('show_outlines', 'showOutlines')

			copy('month_show_border', 'monthShowBorder')
			copy('month_show_weeknumbers', 'monthShowWeekNumbers')
			copy('month_eventbadge_type', 'monthEventBadgeType')
			copy('month_today_style', 'monthTodayStyle')
			copy('month_cell_radius', 'monthCellRadius')

			copy('agenda_newevent_remember_calendar', 'agendaNewEventRememberCalendar')
			copy('agenda_newevent_last_calendar_id', 'agendaNewEventLastCalendarId')
			copy('agenda_weather_show_icon', 'agendaWeatherShowIcon')
			copy('agenda_weather_icon_height', 'agendaWeatherIconHeight')
			copy('agenda_weather_show_text', 'agendaWeatherShowText')
			copy('agenda_breakup_multiday_events', 'agendaBreakupMultiDayEvents')
			copy('agenda_inProgressColor', 'agendaInProgressColor')
			copy('agenda_fontSize', 'agendaFontSize')

			copy('events_pollinterval', 'eventsPollInterval')

			copy('weather_app_id', 'openWeatherMapAppId')
			copy('weather_city_id', 'openWeatherMapCityId')
			copy('weather_canada_city_id', 'weatherCanadaCityId')
			copy('weather_service', 'weatherService')
			copy('weather_units', 'weatherUnits')
			copy('meteogram_hours', 'meteogramHours')
			copy('meteogram_textColor', 'meteogramTextColor')
			copy('meteogram_gridColor', 'meteogramGridColor')
			copy('meteogram_rainColor', 'meteogramRainColor')
			copy('meteogram_positiveTempColor', 'meteogramPositiveTempColor')
			copy('meteogram_negativeTempColor', 'meteogramNegativeTempColor')
			copy('meteogram_iconColor', 'meteogramIconColor')

			plasmoid.configuration.v71Migration = true
		}
	}

}

