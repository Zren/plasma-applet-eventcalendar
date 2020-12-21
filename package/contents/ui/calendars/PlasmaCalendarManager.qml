import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

import "../lib"
import "../Shared.js" as Shared
import "../calendars/PlasmaCalendarUtils.js" as PlasmaCalendarUtils

CalendarManager {
	id: plasmaCalendarManager

	calendarManagerId: "plasma"

	property var executable: ExecUtil { id: executable }
	property var calendarModel: Qt.createQmlObject("import org.kde.plasma.PimCalendars 1.0; PimCalendarsModel {}", plasmaCalendarManager)
	function appendPimCalendars(calendarList) {
		// https://github.com/KDE/kdepim-addons/blob/master/plugins/plasma/pimeventsplugin/PimEventsConfig.qml
		// https://github.com/KDE/kdepim-addons/blob/master/plugins/plasma/pimeventsplugin/pimcalendarsmodel.cpp

		if (!calendarModel) {
			logger.debug('KDEPIM Not installed as PimCalendarsModel import failed.', calendarModel)
			return
		}

		logger.debug('calendarModel', calendarModel)
		logger.debug('calendarModel.count', calendarModel.rowCount())
		var DataRole = Qt.UserRole + 1
		for (var i = 0; i < calendarModel.rowCount(); i++) {
			var index = calendarModel.index(i, 0)
			var calendarName = calendarModel.data(index, Qt.DisplayRole)
			var calendarData = calendarModel.data(index, DataRole)
			logger.debugJSON('PimCalendarsModel', i, calendarName, calendarData)

			if (calendarData['enabled']) {
				var calendarId = "plasma_Events_" + calendarData['id']
				calendarList.push({
					"id": calendarId,
					"summary": calendarName,
					"backgroundColor": "#9a9cff",
					"accessRole": "owner",
					"isTasklist": false,
				})
			}

			if (calendarModel.hasChildren(index)) {
				var parentIndex = index
				for (var j = 0; j < calendarModel.rowCount(parentIndex); j++) {
					var childIndex = calendarModel.index(j, 0, parentIndex)
					var calendarName = calendarModel.data(childIndex, Qt.DisplayRole)
					var calendarData = calendarModel.data(childIndex, DataRole)
					logger.debugJSON('PimCalendarsModel', i, j, calendarName, calendarData)

					if (calendarData['enabled']) {
						var calendarId = "plasma_Events_" + calendarData['id']
						calendarList.push({
							"id": calendarId,
							"summary": calendarName,
							"backgroundColor": "#9a9cff",
							"accessRole": "owner",
							"isTasklist": false,
						})
					}
				}
			}
		}
	}

	//--- CalendarManager
	function getCalendarList() {
		var calendarList = []

		// KHolidays
		calendarList.push({
			"calendarId": "plasma_Holidays",
			"backgroundColor": "" + theme.highlightColor,
			"accessRole": "reader",
			"isTasklist": false,
		})

		// KDEPIM
		appendPimCalendars(calendarList)

		return calendarList
	}

	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/eventpluginsmanager.cpp
	// Plugins are located at:
	//     * (Ubuntu) /usr/lib/x86_64-linux-gnu/qt5/plugins/plasmacalendarplugins/
	//     * (Arch) /usr/lib/qt/plugins/plasmacalendarplugins/
	// DigitalClock's config in ~/.config/plasma-____-appletsrc is:
	//   enabledCalendarPlugins=/usr/lib/.../plugins/plasmacalendarplugins/holidaysevents.so
	// Holidays stores the region in:
	//   ~/.config/plasma_calendar_holiday_regions
	//     [General]
	//     selectedRegions=us_en-us,ru_ru

	// PlasmaCalendar.EventPluginsManager.model is EventPluginsManager::pluginsModel()
	// Which is only useful for the config to select the plugins.
	// We need EventPluginsManager::plugins() to iterate the plugins, but it isn't exposed to QML.
	// So we need to use PlasmaCalendar.Calendar which has a DaysModel property that has a function
	// to get a list of events for a specific day.

	Component.onCompleted: {
		PlasmaCalendarUtils.setEnabledPluginsByFilename(PlasmaCalendar.EventPluginsManager, plasmoid.configuration.enabledCalendarPlugins)
	}
	Connections {
		target: plasmoid.configuration
		onEnabledCalendarPluginsChanged: {
			PlasmaCalendarUtils.setEnabledPluginsByFilename(PlasmaCalendar.EventPluginsManager, plasmoid.configuration.enabledCalendarPlugins)
		}
	}

	// From: kdeclarative/.../MonthView.qml
	PlasmaCalendar.Calendar {
		id: calendarBackend

		days: 7
		weeks: 6
		firstDayOfWeek: {
			if (plasmoid.configuration.firstDayOfWeek == -1) {
				return Qt.locale().firstDayOfWeek
			} else {
				return plasmoid.configuration.firstDayOfWeek
			}
		}
		today: timeModel.currentTime

		Component.onCompleted: {
			//daysModel.connect
			daysModel.setPluginsManager(PlasmaCalendar.EventPluginsManager)
		}
	}

	readonly property string translatedHolidaysType: i18ndc("libplasma5", "Agenda listview section title", "Holidays")
	readonly property string translatedEventsType: i18ndc("libplasma5", "Agenda listview section title", "Events")
	readonly property string translatedTodoType: i18ndc("libplasma5", "Agenda listview section title", "Todo")
	readonly property string translatedOtherType: i18ndc("libplasma5", "Means 'Other calendar items'", "Other")
	function parseCalendarId(dayItem) {
		// dayItem.eventType is translated, but is the only way to tell which plugin it belongs to without
		// creating a seperate PlasmaCalendar.EventPluginsManager for each plugin (assuming it's not a singleton).
		// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/eventdatadecorator.cpp#L60
		// plasma-framework uses the "libplasma5" translation domain.
		if (dayItem.eventType == translatedHolidaysType) {
			return calendarManagerId + "_Holidays"
		} else if (dayItem.eventType == translatedEventsType) {
			return calendarManagerId + "_Events"
		} else if (dayItem.eventType == translatedTodoType) {
			return calendarManagerId + "_Todo"
		} else if (dayItem.eventType == translatedOtherType) {
			return calendarManagerId + "_Other"
		} else {
			return calendarManagerId + "_NotImplemented"
		}
	}

	function parseEventsForDate(day, dayEvents) {
		var items = []
		for (var i = 0; i < dayEvents.length; i++) {
			var dayItem = dayEvents[i]
			// logger.log(JSON.stringify(dayItem, null, '\t'))

			var start = {}
			var end = {}

			// The dayItem.___DateTime might be "Invalid Date"
			// Eg: the "Astronomical Events" plugin
			var startDateTime = new Date(Shared.isValidDate(dayItem.startDateTime) ? dayItem.startDateTime : day)
			var endDateTime = new Date(Shared.isValidDate(dayItem.endDateTime) ? dayItem.endDateTime : day)
			// logger.log('\t startDateTime', dayItem.startDateTime, startDateTime)
			// logger.log('\t endDateTime', dayItem.endDateTime, endDateTime)
			
			if (dayItem.isAllDay) {
				start.date = Shared.localeDateString(startDateTime) // 2018-01-31
				// Google Calendar has the event start at midnight, and end at midnight the next day
				// Plasma has the date end on the same day, so we need to add 1 day to it so
				// the rest of our code stack works.
				var endDate = new Date(endDateTime)
				endDate.setDate(endDate.getDate() + 1)
				end.date = Shared.localeDateString(endDate) // 2018-01-31
				endDateTime = new Date(end.date)
			} else {
				start.dateTime = startDateTime
				end.dateTime = endDateTime
			}
			var calendarId = parseCalendarId(dayItem)
			var eventId = calendarId + "_" + startDateTime.getTime() + "_" + endDateTime.getTime()

			var eventColor = dayItem.eventColor || theme.highlightColor
			eventColor = "" + eventColor // Cast to string, as dayItem.eventColor is a QColor which JSON treats as an object

			var event = {
				"id": eventId,
				"calendarId": calendarId,
				"htmlLink": "",
				"summary": dayItem.title,
				"description": dayItem.description,
				"start": start,
				"end": end,
				"backgroundColor": eventColor,
			}
			items.push(event)
		}
		return items
	}

	function filterEventsIntoCalendars() {

	}

	function getEventsForDate(date) {
		var dayEvents = calendarBackend.daysModel.eventsForDate(date)
		return parseEventsForDate(dayEvents)
	}

	function getEventsForDuration(dateMin, dateMax) {
		var numDays = 0
		for (var day = new Date(dateMin); day < dateMax; day.setDate(day.getDate() + 1)) {
			numDays += 1
		}
		// CalendarBackend needs the actual month we're looking at. We can't arbitrarily grab events for random days.
		var middleDay = new Date(dateMin)
		middleDay.setDate(middleDay.getDate() + Math.floor(numDays/2))
		calendarBackend.displayedDate = middleDay

		var items = []
		
		// 2018-05-24T00:00:00.000Z
		var dateMinUtcStr = Shared.localeDateString(dateMin) + 'T00:00:00.000Z'
		var dateMinUtc = new Date(dateMinUtcStr)
		// logger.debug('getEventsForDuration.dateMinUtcStr', dateMinUtcStr)
		// logger.debug('getEventsForDuration.dateMinUtc', dateMinUtc)

		for (var day = new Date(dateMinUtc); day < dateMax; day.setDate(day.getDate() + 1)) {
			var dayEvents = calendarBackend.daysModel.eventsForDate(day)
			if (dayEvents.length) {
				logger.debugJSON('PlasmaCalendar', day, dayEvents)
			}
			items = items.concat(parseEventsForDate(day, dayEvents))
		}
		// logger.debugJSON(items)

		// We need to filter out the repeated items for multi-day events as Plasma creates a new "event item"
		// for each day of the event.
		for (var i = 0; i < items.length; i++) {
			var itemA = items[i]

			// Check every event before this one.
			for (var j = 0; j < i; j++) {
				var itemB = items[j]
				if (itemA.eventId == itemB.eventId) {
					// There's a conflict, TODO: generate a better eventIds

					if (itemA.start.date == itemB.start.date
						&& itemA.start.dateTime == itemB.start.dateTime
						&& itemA.end.date == itemB.end.date
						&& itemA.end.dateTime == itemB.end.dateTime
						&& itemA.summary == itemB.summary
					) {
						// Same event.

						// logger.debug('itemA == itemB, removing')
						// logger.debugJSON('\titemA', itemA)
						// logger.debugJSON('\titemB', itemB)

						items.splice(i, 1) // remove this event item
						i -= 1 // start this index again
						break // exit j/itemB loop
					}
				}
			}
		}

		return items
	}



	onFetchAllCalendars: {
		var allEvents = getEventsForDuration(dateMin, dateMax)

		// Filter events into seperate calendars
		var calendarIdList = []
		var calendars = {}
		for (var i = 0; i < allEvents.length; i++) {
			var event = allEvents[i]
			if (calendarIdList.indexOf(event.calendarId) == -1) {
				calendarIdList.push(event.calendarId)
				calendars[event.calendarId] = []
			}
			calendars[event.calendarId].push(event)
		}
		for (var i = 0; i < calendarIdList.length; i++) {
			var calendarId = calendarIdList[i]
			var calendarEvents = calendars[calendarId]
			setCalendarData(calendarId, {
				"items": calendarEvents
			})
		}

		// Register calendars we didn't fetch so we can create events with them
		var calendarList = getCalendarList()
		for (var i = 0; i < calendarList.length; i++) {
			var calendar = calendarList[i]
			if (calendarIdList.indexOf(calendar.id) >= 0) {
				continue
			}
			setCalendarData(calendar.id, {
				"items": [],
			})
		}
	}

	onCalendarParsing: {
		var calendar = getCalendar(calendarId)
		parseEventList(calendar, data.items)
	}

	function parseEvent(calendar, event) {
		// event.backgroundColor = calendar.backgroundColor
		event.canEdit = false
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event) {
			parseEvent(calendar, event)
		})
	}

	//--- Create
	function createEvent(calendarId, date, text) {
		if (calendarId.indexOf('plasma_Events_') != 0) {
			logger.log('Could not create event with calendarId=', calendarId)
			return
		}
		var akonadiCalendarId = calendarId.substr('plasma_Events_'.length)
		if (isNaN(parseInt(akonadiCalendarId, 10))) {
			logger.log('Could not parse a proper akonadiCalendarId=', akonadiCalendarId, ' from calendarId=', calendarId)
			return
		}
		var dateString = Shared.dateString(date)

		// konsolekalendar --add --calendar 12 --summary "Summary" --date 2020-07-27 --time 22:00
		var cmd = [
			'konsolekalendar',
			'--add',
			'--calendar',
			akonadiCalendarId,
			'--date',
			dateString,
			'--summary',
			text,
		]
		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr){
			logger.debug('konsolekalendar.cmd', cmd)
			logger.debug('konsolekalendar.exitCode', exitCode)
			logger.debug('konsolekalendar.exitStatus', exitStatus)
			logger.debug('konsolekalendar.stdout', stdout)
			logger.debug('konsolekalendar.stderr', stderr)

			if (exitCode == 0) {
				// It takes a few secs for PIM Events to sync with the PlasmaCalendar API.
				// refresh calls deferredUpdate which is a 200ms delay which seems to work.
				refresh()
			} else {
				// Error
			}
		})
	}
}
