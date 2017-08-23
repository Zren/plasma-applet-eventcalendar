import QtQuick 2.0

import "utils.js" as Utils
import "../code/DebugFixtures.js" as DebugFixtures

CalendarManager {
	id: debugCalendarManager

	function fetchDebugEvents() {
		plasmoid.configuration.debugging = true
		var debugCalendar = DebugFixtures.getCalendar()
		var debugEventData = DebugFixtures.getEventData()
		parseEventList(debugCalendar, debugEventData.items)
		setCalendarData('debug', debugEventData)
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
		Utils.getFile(url, function(err, data) {
			if (err) {
				return callback(err);
			}

			var metadata = Utils.parseMetadata(data)
			callback(null, metadata);
		});
	}

	// Note: Not in use
	// Used to load dumped json events found in debug logs from file.
	// fetchJsonEventsFile(plasmoid.file('', 'testevents.json'), 'testevents@gmail.com') // .../contents/testevents.json
	function fetchJsonEventsFile(filename, calendarId) {
		logger.debug('fetchJsonEventsFile', calendarId)
		debugCalendarManager.asyncRequests += 1
		Utils.getFile(filename, function(err, data) {
			if (err) {
				return callback(err);
			}

			var obj = JSON.parse(data);
			setCalendarData(calendarId, obj)
			debugCalendarManager.asyncRequestsDone += 1
		});
	}


	onFetchAllCalendars: {
		fetchDebugEvents()
		// fetchDebugGoogleSession()
	}

	function parseEvent(calendar, event) {
		event.backgroundColor = calendar.backgroundColor
		event.canEdit = false
		event._summary = event.summary
		event.summary = event.summary || i18nc("event with no summary", "(No title)")
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event) {
			parseEvent(calendar, event)
		})
	}
}
