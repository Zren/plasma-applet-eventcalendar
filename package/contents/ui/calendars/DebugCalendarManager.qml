import QtQuick 2.0

import "../lib/Requests.js" as Requests
import "../../code/DebugFixtures.js" as DebugFixtures

CalendarManager {
	id: debugCalendarManager

	calendarManagerId: "debug"
	property var debugCalendar: null

	function fetchDebugEvents() {
		plasmoid.configuration.debugging = true
		debugCalendar = DebugFixtures.getCalendar()
		var debugEventData = DebugFixtures.getEventData()
		setCalendarData(debugCalendar.id, debugEventData)
	}

	// Note: Not in use
	// Used to load dumped json events found in debug logs from file.
	// fetchJsonEventsFile(plasmoid.file('', 'testevents.json'), 'testevents@gmail.com') // .../contents/testevents.json
	function fetchJsonEventsFile(filename, calendarId) {
		logger.debug('fetchJsonEventsFile', calendarId)
		debugCalendarManager.asyncRequests += 1
		Requests.getFile(filename, function(err, data) {
			if (err) {
				return callback(err)
			}

			var obj = JSON.parse(data)
			setCalendarData(calendarId, obj)
			debugCalendarManager.asyncRequestsDone += 1
		})
	}

	function deleteEvent(calendarId, eventId) {
		var data = getEvent(calendarId, eventId)
		removeEvent(calendarId, eventId)
		eventDeleted(calendarId, eventId, data)
	}


	onFetchAllCalendars: {
		fetchDebugEvents()
	}

	onCalendarParsing: {
		parseEventList(debugCalendar, data.items)
	}

	function parseEvent(calendar, event) {
		event.description = event.description || ""
		event.backgroundColor = calendar.backgroundColor
		event.canEdit = true
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event) {
			parseEvent(calendar, event)
		})
	}

	function setEventProperty(calendarId, eventId, key, value) {
		logger.log('debugCalendarManager.setEventProperty', calendarId, eventId, key, value)
		var event = getEvent(calendarId, eventId)
		if (!event) {
			logger.log('error, trying to update event that doesn\'t exist')
			return
		}
		event[key] = value
		eventUpdated(calendarId, eventId, event)
	}
}
