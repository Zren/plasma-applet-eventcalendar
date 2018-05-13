import QtQuick 2.0

import "../lib/Requests.js" as Requests
import "../../code/DebugFixtures.js" as DebugFixtures

CalendarManager {
	id: debugCalendarManager

	calendarManagerId: "debug"
	property var debugCalendar: null

	property bool showDebugEvents: false
	property bool importGoogleSession: false

	function fetchDebugEvents() {
		plasmoid.configuration.debugging = true
		debugCalendar = DebugFixtures.getCalendar()
		var debugEventData = DebugFixtures.getEventData()
		setCalendarData(debugCalendar.id, debugEventData)
	}

	function fetchDebugGoogleSession() {
		if (plasmoid.configuration.access_token) {
			return
		}
		// Steal access_token from our current user's config.
		fetchCurrentUserConfig(function(err, metadata) {
			plasmoid.configuration.refresh_token = metadata['refresh_token']
			plasmoid.configuration.access_token = metadata['access_token']
			plasmoid.configuration.calendar_id_list = metadata['calendar_id_list']
			plasmoid.configuration.calendar_list = metadata['calendar_list']
		})
	}

	function fetchCurrentUserConfig(callback) {
		var url = 'file:///home/chris/.config/plasma-org.kde.plasma.desktop-appletsrc'
		Requests.getFile(url, function(err, data) {
			if (err) {
				return callback(err);
			}

			var metadata = Requests.parseMetadata(data)
			callback(null, metadata);
		});
	}

	// Note: Not in use
	// Used to load dumped json events found in debug logs from file.
	// fetchJsonEventsFile(plasmoid.file('', 'testevents.json'), 'testevents@gmail.com') // .../contents/testevents.json
	function fetchJsonEventsFile(filename, calendarId) {
		logger.debug('fetchJsonEventsFile', calendarId)
		debugCalendarManager.asyncRequests += 1
		Requests.getFile(filename, function(err, data) {
			if (err) {
				return callback(err);
			}

			var obj = JSON.parse(data);
			setCalendarData(calendarId, obj)
			debugCalendarManager.asyncRequestsDone += 1
		});
	}

	function deleteEvent(calendarId, eventId) {
		var data = getEvent(calendarId, eventId)
		removeEvent(calendarId, eventId)
		eventDeleted(calendarId, eventId, data)
	}


	onFetchAllCalendars: {
		if (showDebugEvents) {
			fetchDebugEvents()
		}
		if (importGoogleSession) {
			fetchDebugGoogleSession()
		}
	}

	onCalendarParsing: {
		parseEventList(debugCalendar, data.items)
	}

	function parseEvent(calendar, event) {
		event.backgroundColor = calendar.backgroundColor
		event.canEdit = true
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event) {
			parseEvent(calendar, event)
		})
	}

	function setEventSummary(calendarId, eventId, summary) {
		console.log('debugCalendarManager.setEventSummary', calendarId, eventId, summary)
		var event = getEvent(calendarId, eventId);
		if (!event) {
			logger.log('error, trying to update event that doesn\'t exist')
			return;
		}
		event.summary = summary
		eventUpdated(calendarId, eventId, event)
	}
}
