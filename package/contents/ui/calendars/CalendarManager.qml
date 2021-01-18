import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: calendarManager

	property string calendarManagerId: ""
	property var eventsByCalendar: ({}) // { "": { "items": [] } }

	property date dateMin: new Date()
	property date dateMax: new Date()

	property bool clearingData: false
	property int asyncRequests: 0
	property int asyncRequestsDone: 0
	signal refresh()
	signal dataCleared()
	signal fetchingData()
	signal calendarFetched(string calendarId, var data)
	signal allDataFetched()
	signal eventAdded(string calendarId, var data)
	signal eventCreated(string calendarId, var data)
	signal eventRemoved(string calendarId, string eventId, var data)
	signal eventDeleted(string calendarId, string eventId, var data)
	signal eventUpdated(string calendarId, string eventId, var data)
	signal error(string msg, int errorType)


	onAsyncRequestsDoneChanged: checkIfDone()

	function checkIfDone() {
		if (clearingData) {
			return
		}
		if (asyncRequestsDone >= asyncRequests) {
			allDataFetched()
		}
	}

	//--- Calendar
	function getCalendarList() {
		return [] // Function is overloaded
	}

	function getCalendar(calendarId) {
		var calendarList = getCalendarList()
		for (var i = 0; i < calendarList.length; i++) {
			var calendar = calendarList[i]
			if (calendarId == calendar.id) {
				return calendar
			}
		}
		return null
	}

	//--- Calendar data
	function setCalendarData(calendarId, data) {
		calendarParsing(calendarId, data)
		eventsByCalendar[calendarId] = data
		calendarFetched(calendarId, data)
	}

	function clear() {
		logger.debug(calendarManager, 'clear()')
		calendarManager.clearingData = true
		calendarManager.asyncRequests = 0
		calendarManager.asyncRequestsDone = 0
		calendarManager.eventsByCalendar = {}
		calendarManager.clearingData = false
		dataCleared()
	}

	//--- Event
	function getEvent(calendarId, eventId) {
		var events = calendarManager.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				return events[i]
			}
		}
	}

	// Add to model only
	function addEvent(calendarId, data) {
		calendarManager.eventsByCalendar[calendarId].items.push(data)
		eventAdded(calendarId, data)
	}

	// Remove from model only
	function removeEvent(calendarId, eventId) {
		logger.debug(calendarManager, 'removeEvent', calendarId, eventId)
		var events = calendarManager.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				var data = events[i]
				events.splice(i, 1) // Remove item at index
				eventRemoved(calendarId, eventId, data)
				return
			}
		}
		logger.log(calendarManager, 'removeEvent', 'event didn\'t exist')
	}

	//---
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
	signal calendarParsing(string calendarId, var data)
	signal eventParsing(string calendarId, var event)

	// Parsing order:
	// CalendarManager.onCalendarParsing
	// CalendarManager.onEventParsing
	// SubClass.onEventParsing
	// CalendarManager.defaultEventParsing
	// SubClass.onCalendarParsing
	onCalendarParsing: {
		// logger.debug('CalendarManager.calendarParsing(', calendarManager, ')', calendarId)
		data.items.forEach(function(event) {
			eventParsing(calendarId, event)
			defaultEventParsing(calendarId, event)
		})
	}
	onEventParsing: {
		// logger.debug('CalendarManager.eventParsing(', calendarManager, ')', calendarId)
	}

	// To simplify repeated code amongst implementations,
	// we'll put the reused code here.
	function defaultEventParsing(calendarId, event) {
		// logger.debug('CalendarManager.defaultEventParsing')
		event.calendarManagerId = calendarManagerId
		event.calendarId = calendarId

		event._summary = event.summary
		event.summary = event.summary || i18nc("event with no summary", "(No title)")

		if (event.start.date) {
			event.startDateTime = new Date(event.start.date + ' 00:00:00')
		} else {
			event.startDateTime = new Date(event.start.dateTime)
		}

		if (event.end.date) {
			event.endDateTime = new Date(event.end.date + ' 00:00:00')
		} else {
			event.endDateTime = new Date(event.end.dateTime)
		}
	}

	function parseSingleEvent(calendarId, event) {
		calendarParsing(calendarId, {
			items: [event],
		})
	}

	//---
	function createEvent(calendarId, date, text) {
		logger.log(calendarManager, 'createEvent(', date, text, ') is not implemented')
	}

	function deleteEvent(calendarId, eventId) {
		logger.log(calendarManager, 'deleteEvent(', calendarId, eventId, ') is not implemented')
	}

	function setEventProperty(calendarId, eventId, key, value) {
		logger.log(calendarManager, 'setEventProperty(', calendarId, eventId, key, value, ') is not implemented')
	}

	function setEventProperties(calendarId, eventId, args) {
		logger.log(calendarManager, 'setEventProperties(', calendarId, eventId, args, ') is not implemented')
	}

}
