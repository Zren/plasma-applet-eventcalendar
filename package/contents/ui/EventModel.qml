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

		onEventCreated: eventModel.eventCreated(calendarId, data)
		onEventRemoved: eventModel.removeEvent(calendarId, eventId)
		onEventDeleted: eventModel.eventDeleted(calendarId, eventId, data)
		onEventUpdated: eventModel.eventUpdated(calendarId, eventId, data)
	}

	function parseEvent(calendar, event) {
		event.backgroundColor = parseColor(calendar, event)
		event.canEdit = calendar.accessRole == 'owner' && !event.recurringEventId // We cannot currently edit repeating events.
		event._summary = event.summary
		event.summary = event.summary || i18nc("event with no summary", "(No title)")
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event){
			parseEvent(calendar, event)
		})
	}

	function parseGoogleCalendarEvent(calendarId, event) {
		event.calendarId = calendarId

		var calendarList = googleCalendarManager.getCalendarList()
		calendarList.forEach(function(calendar){
			if (calendarId == calendar.id) {
				parseEvent(calendar, event)
			}
		})
	}


	function parseGoogleCalendarEvents(calendarId, data) {
		data.items.forEach(function(event){
			event.calendarId = calendarId
		})

		var calendarList = googleCalendarManager.getCalendarList()
		calendarList.forEach(function(calendar){
			if (calendarId == calendar.id) {
				parseEventList(calendar, data.items)
			}
		})
	}

	function parseGCalEvents() {
		var calendarList = googleCalendarManager.getCalendarList()
		eventModel.eventsData = { items: [] }
		for (var calendarId in eventModel.eventsByCalendar) {
			parseGoogleCalendarEvents(calendarId, eventModel.eventsByCalendar[calendarId])
			eventModel.eventsData.items = eventModel.eventsData.items.concat(eventModel.eventsByCalendar[calendarId].items)
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
		// fetchGoogleAccountData()
		googleCalendarManager.fetchAll(dateMin, dateMax)
		// icalManager.fetchAll(dateMin, dateMax)
		debugCalendarManager.fetchAll(dateMin, dateMax)
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
			var data = getEvent(calendarId, eventId)
			removeEvent(calendarId, eventId)
			eventDeleted(calendarId, eventId, data)
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
