import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/DebugFixtures.js" as DebugFixtures
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

	property variant calendarIdList: plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']

	function parseColorId(colorIdType, colorId) {
		// Use hardcoded colorIdMap rather than requesting the list from the API.
		// We could possibly fetch this in the config...
		if (typeof colorId !== "undefined") {
			var typeMap = ColorIdMap.colorIdMap[colorIdType]
			if (typeMap) {
				var colorIdStr = "" + colorId // Cast to string
				if (typeMap[colorIdStr]) {
					return typeMap[colorId]['background']
				}
			}
		}
		return null
	}

	function parseColor(calendar, event) {
		var colorId = parseColorId('event', event.colorId)
		// event.backgroundColor is a hardcoded color (like the debug calendar)
		return event.backgroundColor || colorId || calendar.backgroundColor
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

		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
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

		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
		calendarList.forEach(function(calendar){
			if (calendarId == calendar.id) {
				parseEventList(calendar, data.items)
			}
		})
	}

	function parseGCalEvents() {
		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
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
		fetchGoogleAccountData()
		icalManager.fetchAll(dateMin, dateMax)
		// fetchDebugEvents()
	}

	function fetchDebugEvents() {
		plasmoid.configuration.debugging = true
		var debugCalendar = DebugFixtures.getCalendar()
		var debugEventData = DebugFixtures.getEventData()
		parseEventList(debugCalendar, debugEventData.items)
		setCalendarData('debug', debugEventData)

		fetchDebugGoogleSession()
		// fetchJsonEventsFile(plasmoid.file('', 'testevents.json'), 'testevents@gmail.com') // .../contents/testevents.json
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

	// Used to load dumped json events found in debug logs from file.
	function fetchJsonEventsFile(filename, calendarId) {
		logger.debug('fetchJsonEventsFile', calendarId)
		eventModel.asyncRequests += 1
		Utils.getFile(filename, function(err, data) {
			if (err) {
				return callback(err);
			}

			var obj = JSON.parse(data);
			setCalendarData(calendarId, obj)
			eventModel.asyncRequestsDone += 1
		});
	}

	function fetchGoogleAccountData() {
		if (plasmoid.configuration.access_token) {
			fetchGoogleAccountEvents(plasmoid.configuration.access_token, eventModel.calendarIdList)
		}
	}

	function fetchGoogleAccountEvents(accessToken, calendarIdList) {
		if (accessToken) {
			for (var i = 0; i < calendarIdList.length; i++) {
				fetchGoogleCalendarEvents(accessToken, calendarIdList[i])
			}
		}
	}

	// @param accessToken string
	// @param calendarId string
	// @param dateMin Date
	// @param dateMax Date
	function fetchGoogleCalendarEvents(accessToken, calendarId) {
		logger.debug('fetchGoogleCalendarEvents', calendarId)
		eventModel.asyncRequests += 1
		fetchGCalEvents({
			calendarId: calendarId,
			start: eventModel.dateMin.toISOString(),
			end: eventModel.dateMax.toISOString(),
			access_token: accessToken,
		}, function(err, data, xhr) {
			if (err) {
				logger.logJSON('onGCalError: ', err);
				if (xhr.status === 404) {
					return;
				}
				eventModel.asyncRequestsDone += 1
				return onGCalError(err);
			}

			setCalendarData(calendarId, data)
			eventModel.asyncRequestsDone += 1
		});
	}

	function onGCalError(err) {
		logger.logJSON('onGCalError: ', err);
		deferredUpdateAccessToken.restart()
	}

	function fetchNewAccessToken(callback) {
		logger.debug('fetchNewAccessToken');
		var url = 'https://www.googleapis.com/oauth2/v4/token';
		Utils.post({
			url: url,
			data: {
				client_id: plasmoid.configuration.client_id,
				client_secret: plasmoid.configuration.client_secret,
				refresh_token: plasmoid.configuration.refresh_token,
				grant_type: 'refresh_token',
			},
		}, callback);
	}

	Timer {
		id: deferredUpdateAccessToken
		interval: 200
		onTriggered: eventModel.updateAccessToken()
	}

	function updateAccessToken() {
		// logger.debug('access_token_expires_at', plasmoid.configuration.access_token_expires_at);
		// logger.debug('                    now', Date.now());
		// logger.debug('refresh_token', plasmoid.configuration.refresh_token);
		if (plasmoid.configuration.refresh_token) {
			logger.debug('updateAccessToken');
			fetchNewAccessToken(function(err, data, xhr) {
				if (err || (!err && data && data.error)) {
					return logger.log('Error when using refreshToken:', err, data);
				}
				logger.debug('onAccessToken', data);
				data = JSON.parse(data);

				plasmoid.configuration.access_token = data.access_token;
				plasmoid.configuration.access_token_type = data.token_type;
				plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000;

				deferredUpdate.restart()
			});
		}
	}

	function fetchGCalEvents(args, callback) {
		logger.debug('fetchGCalEvents', args.calendarId);
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events';
		url += '?timeMin=' + encodeURIComponent(args.start);
		url += '&timeMax=' + encodeURIComponent(args.end);
		url += '&singleEvents=' + encodeURIComponent('true');
		url += '&timeZone=' + encodeURIComponent('Etc/UTC');
		Utils.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.access_token,
			}
		}, function(err, data, xhr) {
			logger.debug('fetchGCalEvents.response', args.calendarId, err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
			logger.debugJSON('fetchGCalEvents.response', args.calendarId, data)
			callback(err, data, xhr);
		});
	}


	function createEvent(calendarId, date, text) {
		if (plasmoid.configuration.agenda_newevent_remember_calendar) {
			plasmoid.configuration.agenda_newevent_last_calendar_id = calendarId
		}

		if (calendarId == "debug") {

		} else if (true) { // Google Calendar
			if (plasmoid.configuration.access_token) {
				createGoogleCalendarEvent(plasmoid.configuration.access_token, calendarId, date, text)
			} else {
				logger.log('attempting to create an event without an access token set')
			}
		} else {
			logger.log('cannot create an new event for the calendar', calendarId)
		}
	}

	function createGoogleCalendarEvent(accessToken, calendarId, date, text) {
		if (accessToken) {
			var dateString = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate()
			var eventText = dateString + ' ' + text
			Shared.createGCalEvent({
				access_token: accessToken,
				calendarId: calendarId,
				text: eventText,
			}, function(err, data) {
				// logger.debug(err, JSON.stringify(data, null, '\t'));
				if (eventModel.calendarIdList.indexOf(calendarId) >= 0) {
					eventModel.eventsByCalendar[calendarId].items.push(data)
					eventCreated(calendarId, data)
				}
			})
		}
	}

	function patchGCalEvent(args, callback) {
		// PATCH https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events/';
		url += encodeURIComponent(args.eventId);
		Utils.postJSON({
			// method: 'PATCH', // Note: Qt 5.7+ still doesn't support the PATCH method type
			method: 'PUT',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: args.data,
		}, function(err, data, xhr) {
			logger.debug('patchGCalEvent.response', err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
			callback(err, data, xhr);
		})
	}

	function deleteEvent(calendarId, eventId) {
		if (calendarId == "debug") {
			var data = getEvent(calendarId, eventId)
			removeEvent(calendarId, eventId)
			eventDeleted(calendarId, eventId, data)
		} else if (true) { // Google Calendar
			if (plasmoid.configuration.access_token) {
				deleteGCalEvent({
					accessToken: plasmoid.configuration.access_token,
					calendarId: calendarId,
					eventId: eventId,
				}, function(err, data) {
					// logger.debug(err, JSON.stringify(data, null, '\t'));
					if (eventModel.calendarIdList.indexOf(calendarId) >= 0) {
						removeEvent(calendarId, eventId)
						eventDeleted(calendarId, eventId, data)
					}
				})
			} else {
				logger.log('attempting to delete an event without an access token set')
			}
		} else {
			logger.log('cannot delete an event for the calendar', calendarId)
		}
	}

	function deleteGCalEvent(args, callback) {
		// DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events/';
		url += encodeURIComponent(args.eventId);
		Utils.postJSON({
			method: 'DELETE',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
		}, function(err, data, xhr) {
			logger.debug('deleteGCalEvent.response', err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
			callback(err, data, xhr);
		})
	}

	function getEvent(calendarId, eventId) {
		var events = eventModel.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				return events[i];
			}
		}
	}

	// Remove from model only
	function removeEvent(calendarId, eventId) {
		var events = eventModel.eventsByCalendar[calendarId].items
		for (var i = 0; i < events.length; i++) {
			if (events[i].id == eventId) {
				var data = events[i]
				events.splice(i, 1) // Remove item at index
				eventRemoved(calendarId, eventId, data)
				break
			}
		}
	}


	function setGoogleCalendarEventSummary(accessToken, calendarId, eventId, summary) {
		var event = getEvent(calendarId, eventId);
		if (!event) {
			logger.log('error, trying to set summary for event that doesn\'t exist')
			return;
		}
		
		// Clone the event data and clean up the extra stuff we added in parseGCalEvents()
		var data = JSON.parse(JSON.stringify(event)) // clone
		logger.debugJSON('setGoogleCalendarEventSummary', 'clone', data)
		if (data.start.date) delete data.start.dateTime;
		if (data.end.date) delete data.end.dateTime;
		if (data.end.calendarId) delete data.end.calendarId;
		delete data.canEdit;
		delete data._summary;

		data.summary = summary
		logger.debugJSON('setGoogleCalendarEventSummary', 'final', data)
		
		patchGCalEvent({
			accessToken: accessToken,
			calendarId: calendarId,
			eventId: eventId,
			// data: {
			// 	summary: summary,
			// },
			data: data,
		}, function(err, data, xhr) {
			logger.debug('setGoogleCalendarEventSummary.response', err, data, xhr.status);
			logger.debugJSON('setGoogleCalendarEventSummary.response', data)
			if (data.summary) {
				event.summary = data.summary
			}
			eventUpdated(calendarId, eventId, event)
		})
	}

	function setEventSummary(calendarId, eventId, summary) {
		setGoogleCalendarEventSummary(plasmoid.configuration.access_token, calendarId, eventId, summary)
	}

	function getCalendarList() {
		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
		return calendarList;
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
}
