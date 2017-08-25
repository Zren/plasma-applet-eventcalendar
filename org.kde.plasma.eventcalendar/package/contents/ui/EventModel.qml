import QtQuick 2.0

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/ColorIdMap.js" as ColorIdMap

CalendarManager {
	id: eventModel
	property variant eventsData: { "items": [] }

	ICalManager {
		id: icalManager

		calendarList: appletConfig.icalCalendarList.value

		onFetchingData: eventModel.asyncRequests += 1
		onAllDataFetched: eventModel.asyncRequestsDone += 1
		onCalendarFetched: eventModel.setCalendarData(calendarId, data)
	}

	DebugCalendarManager {
		id: debugCalendarManager

		onFetchingData: eventModel.asyncRequests += 1
		onAllDataFetched: eventModel.asyncRequestsDone += 1
		onCalendarFetched: eventModel.setCalendarData(calendarId, data)
	}

	GoogleCalendarManager {
		id: googleCalendarManager

		onFetchingData: eventModel.asyncRequests += 1
		onAllDataFetched: eventModel.asyncRequestsDone += 1
		onCalendarFetched: eventModel.setCalendarData(calendarId, data)

		onEventAdded: {
			eventModel.mergeEvents()
			eventModel.eventAdded(calendarId, data)
		}
		onEventCreated: eventModel.eventCreated(calendarId, data)
		onEventRemoved: {
			eventModel.mergeEvents()
			eventModel.eventRemoved(calendarId, eventId, data)
		}
		onEventDeleted: eventModel.eventDeleted(calendarId, eventId, data)
		onEventUpdated: {
			eventModel.mergeEvents()
			eventModel.eventUpdated(calendarId, eventId, data)
		}
	}

	property var deferredUpdate: Timer {
		id: deferredUpdate
		interval: 200
		onTriggered: eventModel.update()
	}
	function update() {
		fetchAll()
	}

	onFetchAllCalendars: {
		googleCalendarManager.fetchAll(dateMin, dateMax)
		// icalManager.fetchAll(dateMin, dateMax)
		// debugCalendarManager.fetchAll(dateMin, dateMax)
	}

	onAllDataFetched: mergeEvents()

	function mergeEvents() {
		logger.debug('eventModel.mergeEvents')
		eventModel.eventsData = { items: [] }
		for (var calendarId in eventModel.eventsByCalendar) {
			eventModel.eventsData.items = eventModel.eventsData.items.concat(eventModel.eventsByCalendar[calendarId].items)
		}
	}

	function createEvent(calendarId, date, text) {
		if (plasmoid.configuration.agenda_newevent_remember_calendar) {
			plasmoid.configuration.agenda_newevent_last_calendar_id = calendarId
		}

		if (calendarId == "debug") {

		} else if (true) { // Google Calendar
			if (plasmoid.configuration.access_token) {
				googleCalendarManager.createGoogleCalendarEvent(plasmoid.configuration.access_token, calendarId, date, text)
			} else {
				logger.log('attempting to create an event without an access token set')
			}
		} else {
			logger.log('cannot create an new event for the calendar', calendarId)
		}
	}

	function deleteEvent(calendarId, eventId) {
		if (calendarId == "debug") {
			debugCalendarManager.deleteEvent(calendarId, eventId)
		} else if (true) { // Google Calendar
			googleCalendarManager.deleteEvent(calendarId, eventId)
		} else {
			logger.log('cannot delete an event for the calendar', calendarId)
		}
	}

	function setEventSummary(calendarId, eventId, summary) {
		googleCalendarManager.setGoogleCalendarEventSummary(plasmoid.configuration.access_token, calendarId, eventId, summary)
	}
}
