import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "Shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi

MouseArea {
	id: popup

	onClicked: focus = true

	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * units.devicePixelRatio

	property int topRowHeight: 100 * units.devicePixelRatio
	property int bottomRowHeight: 400 * units.devicePixelRatio
	property int singleColumnMonthViewHeight: 300 * units.devicePixelRatio

	// DigitalClock LeftColumn minWidth: units.gridUnit * 22
	// DigitalClock RightColumn minWidth: units.gridUnit * 14
	// 14/(22+14) * 400 = 156
	// rightColumnWidth=156 looks nice but is very thin for listing events + date + weather.
	property int leftColumnWidth: 400 * units.devicePixelRatio // Meteogram + MonthView
	property int rightColumnWidth: 400 * units.devicePixelRatio // TimerView + AgendaView

	property bool singleColumn: !showAgenda || !showCalendar
	property bool singleColumnFullHeight: !plasmoid.configuration.twoColumns && showAgenda && showCalendar
	property bool twoColumns: plasmoid.configuration.twoColumns && showAgenda && showCalendar

	Layout.minimumWidth: {
		if (twoColumns) {
			return units.gridUnit * 28
		} else {
			return units.gridUnit * 14
		}
	}
	Layout.preferredWidth: {
		if (twoColumns) {
			return (leftColumnWidth + spacing + rightColumnWidth) + padding * 2
		} else {
			return leftColumnWidth + padding * 2
		}
	}

	Layout.minimumHeight: units.gridUnit * 14
	Layout.preferredHeight: {
		if (singleColumnFullHeight) {
			return plasmoid.screenGeometry.height
		} else if (singleColumn) {
			var h = bottomRowHeight // showAgenda || showCalendar
			if (showMeteogram) {
				h += spacing + topRowHeight
			}
			if (showTimer) {
				h += spacing + topRowHeight
			}
			return h + padding * 2
		} else { // twoColumns
			var h = bottomRowHeight // showAgenda || showCalendar
			if (showMeteogram || showTimer) {
				h += spacing + topRowHeight
			}
			return h + padding * 2
		}
	}

	property var eventModel
	property var agendaModel

	property bool showMeteogram: plasmoid.configuration.widget_show_meteogram
	property bool showTimer: plasmoid.configuration.widget_show_timer
	property bool showAgenda: plasmoid.configuration.widget_show_agenda
	property bool showCalendar: plasmoid.configuration.widget_show_calendar
	property bool agendaScrollOnSelect: true
	property bool cfg_agenda_scroll_on_monthchange: false

	property alias today: monthView.today
	property alias selectedDate: monthView.currentDate
	property alias monthViewDate: monthView.displayedDate
	property var dailyWeatherData: { "list": [] }
	property var hourlyWeatherData: { "list": [] }
	property var currentWeatherData: null
	property var lastForecastAt: null
	property var lastForecastErr: null

	Connections {
		target: monthView
		onDateSelected: {
			// logger.debug('onDateSelected', selectedDate)
			scrollToSelection()
		}
	}
	function scrollToSelection() {
		if (!agendaScrollOnSelect) {
			return
		}

		if (true) {
			agendaView.scrollToDate(selectedDate)
		} else {
			agendaView.scrollToTop()
		}
	}

	Connections {
		target: plasmoid.configuration
		onWeather_serviceChanged: {
			popup.dailyWeatherData = { "list": [] }
			popup.hourlyWeatherData = { "list": [] }
			popup.currentWeatherData = null
			popup.updateUI()
		}
	}

	onMonthViewDateChanged: {
		logger.debug('onMonthViewDateChanged', monthViewDate)
		var startOfMonth = new Date(monthViewDate)
		startOfMonth.setDate(1)
		agendaModel.currentMonth = new Date(startOfMonth)
		if (cfg_agenda_scroll_on_monthchange) {
			selectedDate = startOfMonth
		}
		updateEvents()
	}

	onStateChanged: {
		// logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
	}
	states: [
		State {
			name: "calendar"
			when: !popup.showAgenda && popup.showCalendar && !popup.showMeteogram && !popup.showTimer

			PropertyChanges { target: popup
				// Use the same size as the digitalclock popup
				// since we don't need more space to fit more agenda items.
				Layout.preferredWidth: 378 * units.devicePixelRatio
				Layout.preferredHeight: 378 * units.devicePixelRatio
			}
			PropertyChanges { target: monthView
				Layout.preferredWidth: -1
				Layout.preferredHeight: -1
			}
		},
		State {
			name: "twoColumns+agenda+month"
			when: popup.twoColumns && popup.showAgenda && popup.showCalendar && !popup.showMeteogram && !popup.showTimer

			PropertyChanges { target: widgetGrid
				columns: 2
				rows: 1
			}
		},
		State {
			name: "twoColumns+meteogram+agenda+month"
			when: popup.twoColumns && popup.showAgenda && popup.showCalendar && popup.showMeteogram && !popup.showTimer

			PropertyChanges { target: widgetGrid
				columns: 2
				rows: 2
			}
			PropertyChanges { target: meteogramView
				Layout.columnSpan: 2
			}
		},
		State {
			name: "twoColumns+timer+agenda+month"
			when: popup.twoColumns && popup.showAgenda && popup.showCalendar && !popup.showMeteogram && popup.showTimer

			PropertyChanges { target: widgetGrid
				columns: 2
				rows: 2
			}
			AnchorChanges { target: timerView
				anchors.top: widgetGrid.top
				anchors.left: widgetGrid.left
			}
			AnchorChanges { target: monthView
				anchors.top: timerView.bottom
				anchors.left: widgetGrid.left
				anchors.bottom: widgetGrid.bottom
			}
			PropertyChanges { target: monthView
				anchors.topMargin: widgetGrid.rowSpacing
			}
			AnchorChanges { target: agendaView
				anchors.top: widgetGrid.top
				anchors.right: widgetGrid.right
				anchors.bottom: widgetGrid.bottom
			}
		},
		State {
			name: "twoColumns+meteogram+timer+agenda+month"
			when: popup.twoColumns && popup.showAgenda && popup.showCalendar && popup.showMeteogram && popup.showTimer

			PropertyChanges { target: widgetGrid
				columns: 2
				rows: 2
			}
		},
		State {
			name: "singleColumnFullHeight"
			when: !popup.twoColumns && popup.showAgenda && popup.showCalendar

			PropertyChanges { target: widgetGrid
				columns: 1
				anchors.margins: 0
				anchors.topMargin: popup.padding
			}
			PropertyChanges { target: meteogramView
				Layout.maximumHeight: popup.topRowHeight
			}
			PropertyChanges { target: timerView
				Layout.maximumHeight: popup.topRowHeight
			}
			PropertyChanges { target: monthView
				Layout.minimumHeight: popup.singleColumnMonthViewHeight
				Layout.preferredHeight: popup.singleColumnMonthViewHeight
				Layout.maximumHeight: popup.singleColumnMonthViewHeight
			}
			PropertyChanges { target: agendaView
				// Layout.minimumHeight: popup.bottomRowHeight
				Layout.preferredHeight: popup.bottomRowHeight
			}
		},
		State {
			name: "singleColumn"
			when: !popup.showAgenda || !popup.showCalendar

			PropertyChanges { target: widgetGrid
				columns: 1
			}
			PropertyChanges { target: meteogramView
				Layout.maximumHeight: popup.topRowHeight * 1.5 // 150%
			}
			PropertyChanges { target: timerView
				Layout.maximumHeight: popup.topRowHeight
			}
		}
	]

	GridLayout {
		id: widgetGrid
		anchors.fill: parent
		anchors.margins: popup.padding
		columnSpacing: popup.spacing
		rowSpacing: popup.spacing
		onColumnsChanged: {
			// logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
		}
		onRowsChanged: {
			// logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
		}


		MeteogramView {
			id: meteogramView
			visible: showMeteogram
			Layout.fillWidth: true
			Layout.minimumHeight: popup.topRowHeight
			Layout.preferredHeight: parent.height / 5
			visibleDuration: plasmoid.configuration.meteogram_hours
			showIconOutline: plasmoid.configuration.show_outlines
			xAxisScale: 1 / hoursPerDataPoint
			xAxisLabelEvery: Math.ceil(3 / hoursPerDataPoint)
			property int hoursPerDataPoint: WeatherApi.getDataPointDuration()

			Rectangle {
				id: meteogramMessageBox
				anchors.fill: parent
				anchors.margins: units.smallSpacing
				color: "transparent"
				border.color: theme.buttonBackgroundColor
				border.width: 1

				readonly property string message: {
					if (!WeatherApi.weatherIsSetup()) {
						return i18n("Weather not configured.\nGo to Weather in the config and set your city,\nand/or disable the meteogram to hide this area.")
					} else if (lastForecastErr && !meteogramView.populated) {
						return i18n("Error fetching weather.") + '\n' + lastForecastErr
					} else {
						return ''
					}
				}

				visible: !!message

				PlasmaComponents.Label {
					text: meteogramMessageBox.message
					anchors.fill: parent
					fontSizeMode: Text.Fit
					wrapMode: Text.Wrap
					horizontalAlignment: Text.AlignHCenter
					verticalAlignment: Text.AlignVCenter
				}
			}
		}

		TimerView {
			id: timerView
			visible: showTimer
			Layout.fillWidth: true
			Layout.minimumHeight: Math.max(popup.topRowHeight, implicitHeight)
			Layout.preferredHeight: parent.height / 5
		}

		MonthView {
			id: monthView
			visible: showCalendar
			borderOpacity: plasmoid.configuration.month_show_border ? 0.25 : 0
			showWeekNumbers: plasmoid.configuration.month_show_weeknumbers
			highlightCurrentDayWeek: plasmoid.configuration.monthHighlightCurrentDayWeek

			Layout.preferredWidth: parent.width/2
			Layout.fillWidth: true
			Layout.fillHeight: true

			// Component.onCompleted: {
			// 	today = new Date()
			// }

			function parseGCalEvents(data) {
				if (!(data && data.items)) {
					return
				}

				// Clear event data since data contains events from all calendars, and this function
				// is called every time a calendar is recieved.
				for (var i = 0; i < monthView.daysModel.count; i++) {
					var dayData = monthView.daysModel.get(i)
					monthView.daysModel.setProperty(i, 'showEventBadge', false)
					dayData.events.clear()
				}

				// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/daysmodel.h
				for (var j = 0; j < data.items.length; j++) {
					var eventItem = data.items[j]
					var eventItemStartDate = new Date(eventItem.startDateTime.getFullYear(), eventItem.startDateTime.getMonth(), eventItem.startDateTime.getDate())
					var eventItemEndDate = new Date(eventItem.endDateTime.getFullYear(), eventItem.endDateTime.getMonth(), eventItem.endDateTime.getDate())
					if (eventItem.end.date) {
						// All day events end at midnight which is technically the next day.
						eventItemEndDate.setDate(eventItemEndDate.getDate() - 1)
					}
					// logger.debug(eventItemStartDate, eventItemEndDate)
					for (var i = 0; i < monthView.daysModel.count; i++) {
						var dayData = monthView.daysModel.get(i)
						var dayDataDate = new Date(dayData.yearNumber, dayData.monthNumber - 1, dayData.dayNumber)
						if (eventItemStartDate <= dayDataDate && dayDataDate <= eventItemEndDate) {
							// logger.debug('\t', dayDataDate)
							monthView.daysModel.setProperty(i, 'showEventBadge', true)
							var events = dayData.events || []
							events.append(eventItem)
							monthView.daysModel.setProperty(i, 'events', events)
						} else if (eventItemEndDate < dayDataDate) {
							break
						}
					}
				}
			}

			onDayDoubleClicked: {
				var date = new Date(dayData.yearNumber, dayData.monthNumber-1, dayData.dayNumber)
				// logger.debug('Popup.monthView.onDoubleClicked', date)
				if (true) {
					// cfg_month_day_doubleclick == "browser_newevent"
					Shared.openGoogleCalendarNewEventUrl(date)
				}
			}
		} // MonthView

		AgendaView {
			id: agendaView
			visible: showAgenda

			Layout.preferredWidth: parent.width / 2
			Layout.fillWidth: true
			Layout.fillHeight: true

			function populateCalendarSelector(calendarSelector, selectedCalendarId) {
				if (plasmoid.configuration.access_token) {
					var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']
					var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : []
					// logger.debug('calendarList', JSON.stringify(calendarList, null, '\t'))
					var list = []
					var selectedIndex = 0
					calendarList.forEach(function(calendar){
						var canEditCalendar = calendar.accessRole == 'writer' || calendar.accessRole == 'owner'
						var isSelected = calendar.id === selectedCalendarId

						if (isSelected) {
							selectedIndex = list.length // index after insertion
						}

						if (canEditCalendar || isSelected) {
							list.push({
								'calendarId': calendar.id,
								'text': calendar.summary,
								'backgroundColor': calendar.backgroundColor,
							})
						}
					})
					calendarSelector.model = list
					calendarSelector.currentIndex = selectedIndex
				}
			}
			onNewEventFormOpened: {
				// logger.debug('onNewEventFormOpened')
				var selectedCalendarId = ""
				if (plasmoid.configuration.agenda_newevent_remember_calendar) {
					selectedCalendarId = plasmoid.configuration.agenda_newevent_last_calendar_id
				}
				populateCalendarSelector(newEventCalendarId, selectedCalendarId)
			}
			onSubmitNewEventForm: {
				// logger.debug('onSubmitNewEventForm', calendarId)
				if (plasmoid.configuration.access_token) {
					logger.debug(calendarId)
					eventModel.createEvent(calendarId, date, text)
				}
			}
			PlasmaComponents.Button {
				iconSource: 'view-refresh'
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				anchors.rightMargin: agendaView.scrollbarWidth
				onClicked: {
					updateEvents()
					updateWeather()
				}

				// Timer {
				// 	running: true
				// 	repeat: true
				// 	interval: 2000
				// 	onTriggered: parent.clicked()
				// }
			}
		} // AgendaView
	} // GridLayout

	Component.onCompleted: {
		update()
		polltimer.start()
	}

	Timer {
		id: polltimer
		
		repeat: true
		triggeredOnStart: true
		interval: plasmoid.configuration.events_pollinterval * 60000
		onTriggered: update()
	}

	function update() {
		logger.debug('update')
		updateData()
	}

	function updateData() {
		logger.debug('updateData')
		updateEvents()
		updateWeather()
	}

	function updateEvents() {
		updateEventsTimer.restart()
	}
	Timer {
		id: updateEventsTimer
		interval: 200
		onTriggered: deferredUpdateEvents()
	}

	Connections {
		target: eventModel
		onCalendarFetched: {
			logger.log('onCalendarFetched', calendarId)
			// logger.debug('onCalendarFetched', calendarId, JSON.stringify(data, null, '\t'))
			popup.deferredUpdateUI()
		}
		onAllDataFetched: {
			// logger.log('onAllDataFetched')
			popup.deferredUpdateUI()
		}
		onEventCreated: {
			logger.logJSON('onEventCreated', calendarId, data)
			popup.deferredUpdateUI()
		}
		onEventUpdated: {
			logger.logJSON('onEventUpdated', calendarId, eventId, data)
			popup.deferredUpdateUI()
		}
		onEventDeleted: {
			logger.logJSON('onEventDeleted', calendarId, eventId, data)
			popup.deferredUpdateUI()
		}
	}
	function deferredUpdateEvents() {
		var dateMin = monthView.firstDisplayedDate()
		if (!dateMin) {
			// logger.log('updateEvents', 'no dateMin')
			return
		}
		var monthViewDateMax = monthView.lastDisplayedDate()
		var agendaViewDateMax = new Date(today).setDate(today.getDate() + 14)
		var dateMax
		if (monthViewDate.getYear() == today.getYear() && monthViewDate.getMonth() == today.getMonth()) {
			dateMax = new Date(Math.max(monthViewDateMax, agendaViewDateMax))
		} else {
			dateMax = monthViewDateMax
		}


		agendaModel.visibleDateMin = dateMin
		agendaModel.visibleDateMax = dateMax
		eventModel.fetchAll(dateMin, dateMax)
	}

	function updateWeather(force) {
		if (WeatherApi.weatherIsSetup()) {
			// update every hour
			var shouldUpdate = false
			if (lastForecastAt) {
				var now = new Date()
				var currentHour = now.getHours()
				var lastUpdateHour = new Date(lastForecastAt).getHours()
				var beenOverAnHour = now.valueOf() - lastForecastAt >= 60 * 60 * 1000
				if (lastUpdateHour != currentHour || beenOverAnHour) {
					shouldUpdate = true
				}
			} else {
				shouldUpdate = true
			}
			
			if (force || shouldUpdate) {
				updateWeatherTimer.restart()
			}
		}
	}
	Timer {
		id: updateWeatherTimer
		interval: 100
		onTriggered: deferredUpdateWeather()
	}
	function deferredUpdateWeather() {
		updateDailyWeather()

		if (popup.showMeteogram) {
			updateHourlyWeather()
		}
	}

	function handleWeatherError(funcName, err, data, xhr) {
		logger.log(funcName + '.err', err, xhr && xhr.status, data)
		lastForecastAt = Date.now() // If there's an error, don't bother the API for another hour.
		if (xhr && xhr.status == 429) {
			lastForecastErr = i18n("Weather API limit reached, will try again soon.")
		} else {
			lastForecastErr = err
		}
	}

	function updateDailyWeather() {
		logger.debug('updateDailyWeather', lastForecastAt, Date.now())
		WeatherApi.updateDailyWeather(function(err, data, xhr) {
			if (err) return handleWeatherError('updateDailyWeather', err, data, xhr)
			logger.debugJSON('updateDailyWeather.response', data)

			lastForecastAt = Date.now()
			lastForecastErr = null
			dailyWeatherData = data
			updateUI()
		})
	}

	function updateHourlyWeather() {
		logger.debug('updateHourlyWeather', lastForecastAt, Date.now())
		WeatherApi.updateHourlyWeather(function(err, data, xhr) {
			if (err) return handleWeatherError('updateHourlyWeather', err, data, xhr)
			logger.debugJSON('updateHourlyWeather.response', data)

			lastForecastAt = Date.now()
			lastForecastErr = null
			hourlyWeatherData = data
			currentWeatherData = data.list[0]
			meteogramView.parseWeatherForecast(currentWeatherData, hourlyWeatherData)
		})
	}

	Timer {
		id: updateUITimer
		interval: 100
		onTriggered: popup.updateUI()
	}
	function deferredUpdateUI() {
		updateUITimer.restart()
	}

	function updateUI() {
		// logger.debug('updateUI')
		var now = new Date()

		if (updateUITimer.running) {
			updateUITimer.running = false
		}

		if (monthViewDate.getYear() == now.getYear() && monthViewDate.getMonth() == now.getMonth()) {
			agendaModel.showNextNumDays = 14
			agendaModel.clipPastEvents = false
		} else {
			agendaModel.showNextNumDays = 0
			agendaModel.clipPastEvents = false
		}

		agendaModel.parseGCalEvents(eventModel.eventsData)
		agendaModel.parseWeatherForecast(dailyWeatherData)
		monthView.parseGCalEvents(eventModel.eventsData)
		scrollToSelection()
	}
}
