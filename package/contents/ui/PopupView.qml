import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "lib"
import "Shared.js" as Shared
import "./weather/WeatherApi.js" as WeatherApi

MouseArea {
	id: popup

	onClicked: focus = true

	property int padding: 0 // Assigned in main.qml
	property int spacing: 10 * units.devicePixelRatio

	property int topRowHeight: plasmoid.configuration.topRowHeight * units.devicePixelRatio
	property int bottomRowHeight: plasmoid.configuration.bottomRowHeight * units.devicePixelRatio
	property int singleColumnMonthViewHeight: plasmoid.configuration.monthHeightSingleColumn * units.devicePixelRatio

	// DigitalClock LeftColumn minWidth: units.gridUnit * 22
	// DigitalClock RightColumn minWidth: units.gridUnit * 14
	// 14/(22+14) * 400 = 156
	// rightColumnWidth=156 looks nice but is very thin for listing events + date + weather.
	property int leftColumnWidth: plasmoid.configuration.leftColumnWidth * units.devicePixelRatio // Meteogram + MonthView
	property int rightColumnWidth: plasmoid.configuration.rightColumnWidth * units.devicePixelRatio // TimerView + AgendaView

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

	property bool showMeteogram: plasmoid.configuration.widgetShowMeteogram
	property bool showTimer: plasmoid.configuration.widgetShowTimer
	property bool showAgenda: plasmoid.configuration.widgetShowAgenda
	property bool showCalendar: plasmoid.configuration.widgetShowCalendar
	property bool agendaScrollOnSelect: true
	property bool agendaScrollOnMonthChange: false

	property alias today: monthView.today
	property alias selectedDate: monthView.currentDate
	property alias monthViewDate: monthView.displayedDate

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

	onMonthViewDateChanged: {
		logger.debug('onMonthViewDateChanged', monthViewDate)
		var startOfMonth = new Date(monthViewDate)
		startOfMonth.setDate(1)
		agendaModel.currentMonth = new Date(startOfMonth)
		if (agendaScrollOnMonthChange) {
			selectedDate = startOfMonth
		}
		logic.updateEvents()
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
			Layout.preferredWidth: popup.leftColumnWidth
			Layout.preferredHeight: popup.topRowHeight
			visibleDuration: plasmoid.configuration.meteogramHours
			showIconOutline: plasmoid.configuration.showOutlines
			xAxisScale: 1 / hoursPerDataPoint
			xAxisLabelEvery: Math.ceil(3 / hoursPerDataPoint)
			property int hoursPerDataPoint: WeatherApi.getDataPointDuration(plasmoid.configuration)
			rainUnits: WeatherApi.getRainUnits(plasmoid.configuration)

			Rectangle {
				id: meteogramMessageBox
				anchors.fill: parent
				anchors.margins: units.smallSpacing
				color: "transparent"
				border.color: theme.buttonBackgroundColor
				border.width: 1

				readonly property string message: {
					if (!WeatherApi.weatherIsSetup(plasmoid.configuration)) {
						return i18n("Weather not configured.\nGo to Weather in the config and set your city,\nand/or disable the meteogram to hide this area.")
					} else if (logic.lastForecastErr) {
						return i18n("Error fetching weather.") + '\n' + logic.lastForecastErr
					} else {
						return ''
					}
				}

				visible: !!message

				PlasmaComponents3.Label {
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
			Layout.preferredWidth: popup.rightColumnWidth
			Layout.preferredHeight: popup.topRowHeight
		}

		MonthView {
			id: monthView
			visible: showCalendar
			borderOpacity: plasmoid.configuration.monthShowBorder ? 0.25 : 0
			showWeekNumbers: plasmoid.configuration.monthShowWeekNumbers
			highlightCurrentDayWeek: plasmoid.configuration.monthHighlightCurrentDayWeek

			Layout.preferredWidth: popup.leftColumnWidth
			Layout.preferredHeight: popup.bottomRowHeight
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
				var doubleClickOption = plasmoid.configuration.monthDayDoubleClick

				switch (doubleClickOption) {
					case 'GoogleCalWeb':
						Shared.openGoogleCalendarNewEventUrl(date)
						return
					default:
						return
				}
			}
		} // MonthView

		AgendaView {
			id: agendaView
			visible: showAgenda

			Layout.preferredWidth: popup.rightColumnWidth
			Layout.preferredHeight: popup.bottomRowHeight
			Layout.fillWidth: true
			Layout.fillHeight: true

			onNewEventFormOpened: {
				// logger.debug('onNewEventFormOpened')
				var selectedCalendarId = ""
				if (plasmoid.configuration.agendaNewEventRememberCalendar) {
					selectedCalendarId = plasmoid.configuration.agendaNewEventLastCalendarId
				}
				var calendarList = eventModel.getCalendarList()
				calendarSelector.populate(calendarList, selectedCalendarId)
			}
			onSubmitNewEventForm: {
				logger.debug('onSubmitNewEventForm', calendarId)
				eventModel.createEvent(calendarId, date, text)
			}

			MessageWidget {
				id: errorMessageWidget
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				anchors.right: refreshButton.left
				anchors.margins: PlasmaCore.Units.smallSpacing
				text: logic.currentErrorMessage
			}

			PlasmaComponents3.Button {
				id: refreshButton
				icon.name: 'view-refresh'
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				anchors.rightMargin: agendaView.scrollbarWidth
				onClicked: {
					logic.update()
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

	function updateMeteogram() {
		meteogramView.parseWeatherForecast(logic.currentWeatherData, logic.hourlyWeatherData)
	}

	function showError(msg) {
		errorMessageWidget.warn(msg)
	}

	function clearError() {
		errorMessageWidget.close()
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

		agendaModel.parseGCalEvents(eventModel.eventsData)
		agendaModel.parseWeatherForecast(logic.dailyWeatherData)
		monthView.parseGCalEvents(eventModel.eventsData)
		scrollToSelection()
	}
}
