import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: calendarManager

	property variant eventsByCalendar: { return {} } // { "": { "items": [] } }

	property date dateMin: new Date()
	property date dateMax: new Date()

	property int asyncRequests: 0
	property int asyncRequestsDone: 0
	signal dataCleared()
	signal fetchingData()
	signal calendarFetched(string calendarId, var data)
	signal allDataFetched()
	signal eventCreated(string calendarId, var data)
	signal eventRemoved(string calendarId, string eventId, var data)
	signal eventDeleted(string calendarId, string eventId, var data)
	signal eventUpdated(string calendarId, string eventId, var data)


	onAsyncRequestsDoneChanged: checkIfDone()

	function checkIfDone() {
		if (asyncRequestsDone >= asyncRequests) {
			allDataFetched()
		}
	}

	function setCalendarData(calendarId, data) {
		eventsByCalendar[calendarId] = data
		calendarFetched(calendarId, data)
	}

	function clear() {
		logger.debug(calendarManager, 'clear()')
		calendarManager.asyncRequests = 0
		calendarManager.asyncRequestsDone = 0
		calendarManager.eventsByCalendar = {}
		dataCleared()
	}

	function getEvent(calendarId, eventId) {
		var events = calendarManager.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				return events[i];
			}
		}
	}

	// Remove from model only
	function removeEvent(calendarId, eventId) {
		var events = calendarManager.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				var data = events[i]
				events.splice(i, 1) // Remove item at index
				eventRemoved(calendarId, eventId, data)
				break
			}
		}
	}

	function fetchAll(dateMin, dateMax) {
		logger.debug(calendarManager, 'fetchAllEvents', dateMin, dateMax)
		fetchingData()
		clear()
		if (typeof dateMin !== "undefined") {
			calendarManager.dateMin = dateMin
			calendarManager.dateMax = dateMax
		}
		fetchAllCalendars()
		checkIfDone()
	}

	// Implementation
	signal fetchAllCalendars()
}
