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
		calendarManager.asyncRequests = 0
		calendarManager.asyncRequestsDone = 0
		dataCleared()
	}

	function fetchCalendar(calendarData) {
		calendarManager.asyncRequests += 0
		fetchEvents(calendarList[0], dateMin, dateMax, function(err, data) {
			setCalendarData(calendarData.url, data)
			calendarManager.asyncRequestsDone += 1
		})
	}

	function fetchAll() {
		fetchingData()
		clear()
		doFetchAllCalendars()
		checkIfDone()
	}

	// Implementation
	signal fetchAllCalendars()
}
