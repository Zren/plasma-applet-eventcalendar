import QtQuick 2.0

import "./lib/Requests.js" as Requests
import "Shared.js" as Shared
import "./calendars"
import "../code/ColorIdMap.js" as ColorIdMap

CalendarManager {
	id: eventModel

	property var calendarPluginMap: ({}) // Empty Map
	property var eventsData: { "items": [] }

	function fetchingDataListener() { eventModel.asyncRequests += 1 }
	function allDataFetchedListener() { eventModel.asyncRequestsDone += 1 }
	function calendarFetchedListener(calendarId, data) {
		eventModel.setCalendarData(calendarId, data)
	}
	function eventAddedListener(calendarId, data) {
		eventModel.mergeEvents()
		eventModel.eventAdded(calendarId, data)
	}
	function eventCreatedListener(calendarId, data) {
		eventModel.eventCreated(calendarId, data)
	}
	function eventRemovedListener(calendarId, eventId, data) {
		eventModel.mergeEvents()
		eventModel.eventRemoved(calendarId, eventId, data)
	}
	function eventDeletedListener(calendarId, eventId, data) {
		eventModel.eventDeleted(calendarId, eventId, data)
	}
	function eventUpdatedListener(calendarId, eventId, data) {
		eventModel.mergeEvents()
		eventModel.eventUpdated(calendarId, eventId, data)
	}

	function bindSignals(calendarManager) {
		console.log('bindSignals', calendarManager)
		calendarManager.fetchingData.connect(fetchingDataListener)
		calendarManager.allDataFetched.connect(allDataFetchedListener)
		calendarManager.calendarFetched.connect(calendarFetchedListener)

		calendarManager.calendarFetched.connect(function(calendarId, data){
			eventModel.calendarPluginMap[calendarId] = calendarManager
		})

		calendarManager.eventAdded.connect(eventAddedListener)
		calendarManager.eventCreated.connect(eventCreatedListener)
		calendarManager.eventRemoved.connect(eventRemovedListener)
		calendarManager.eventDeleted.connect(eventDeletedListener)
		calendarManager.eventUpdated.connect(eventUpdatedListener)
	}

	function getCalendarManager(calendarId) {
		return eventModel.calendarPluginMap[calendarId]
	}

	ICalManager {
		id: icalManager
		calendarList: appletConfig.icalCalendarList.value
	}

	DebugCalendarManager {
		id: debugCalendarManager
	}

	GoogleCalendarManager {
		id: googleCalendarManager
	}

	PlasmaCalendarManager {
		id: plasmaCalendarManager
	}

	Component.onCompleted: {
		bindSignals(icalManager)
		bindSignals(debugCalendarManager)
		bindSignals(googleCalendarManager)
		bindSignals(plasmaCalendarManager)
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
		plasmaCalendarManager.fetchAll(dateMin, dateMax)
		// icalManager.fetchAll(dateMin, dateMax)
		// debugCalendarManager.showDebugEvents = true
		// debugCalendarManager.importGoogleSession = true
		// debugCalendarManager.fetchAll(dateMin, dateMax)
	}

	onAllDataFetched: mergeEvents()

	function mergeEvents() {
		logger.debug('eventModel.mergeEvents')
		delete eventModel.eventsData
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
			logger.log('cannot delete an event for the calendar', calendarId, eventId)
		}
	}

	function setEventSummary(calendarId, eventId, summary) {
		console.log('eventModel.setEventSummary', calendarId, eventId, summary)
		if (calendarId == "debug") {
			debugCalendarManager.setEventSummary(calendarId, eventId, summary)
		} else if (true) { // Google Calendar
			googleCalendarManager.setGoogleCalendarEventSummary(plasmoid.configuration.access_token, calendarId, eventId, summary)
		} else {
			logger.log('cannot edit the event summary for the calendar', calendarId, eventId)
		}
	}
}
