import QtQuick 2.0

import "../lib/Requests.js" as Requests

CalendarManager {
	id: debugCalendarManager

	calendarManagerId: "DebugGoogleCalendar"

	function fetchDebugGoogleSession() {
		if (plasmoid.configuration.access_token) {
			return
		}
		// Steal access_token from our current user's config.
		fetchCurrentUserConfig(function(err, metadata) {
			plasmoid.configuration.refresh_token = metadata['refresh_token']
			plasmoid.configuration.access_token = metadata['access_token']
			plasmoid.configuration.access_token_type = metadata['access_token_type']
			plasmoid.configuration.access_token_expires_at = metadata['access_token_expires_at']
			plasmoid.configuration.calendar_id_list = metadata['calendar_id_list']
			plasmoid.configuration.calendar_list = metadata['calendar_list']
			plasmoid.configuration.tasklistIdList = metadata['tasklistIdList']
			plasmoid.configuration.tasklistList = metadata['tasklistList']
			plasmoid.configuration.agenda_newevent_last_calendar_id = metadata['agenda_newevent_last_calendar_id']
		})
	}

	function fetchCurrentUserConfig(callback) {
		var url = 'file:///home/chris/.config/plasma-org.kde.plasma.desktop-appletsrc'
		Requests.getFile(url, function(err, data) {
			if (err) {
				return callback(err)
			}

			var metadata = Requests.parseMetadata(data)
			callback(null, metadata)
		})
	}

	onFetchAllCalendars: {
		fetchDebugGoogleSession()
	}
}
