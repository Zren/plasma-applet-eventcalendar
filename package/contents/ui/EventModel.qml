import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/DebugFixtures.js" as DebugFixtures

Item {
	id: eventModel
	property variant eventsData: { "items": [] }
	property variant eventsByCalendar: { "": { "items": [] } }
	property date dateMin: new Date()
	property date dateMax: new Date()
	property variant calendarIdList: plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']

	property int asyncRequests: 0
	property int asyncRequestsDone: 0
	signal dataCleared()
	signal fetchingData()
	signal calendarFetched(string calendarId, var data)
	signal allDataFetched()
	signal eventCreated(string calendarId, var data)
	signal eventUpdated(string calendarId, var data)

	onAsyncRequestsDoneChanged: checkIfDone()

	Component.onCompleted: {
		delete eventModel.eventsByCalendar[''] // Is there really no way to initialize an empty JSON object?
	}

	function clear() {
		console.log('eventModel.clear()')
		asyncRequests = 0
		asyncRequestsDone = 0
		eventModel.eventsByCalendar = {}
		dataCleared()
	}

	function setCalendarData(calendarId, data) {
		eventModel.eventsByCalendar[calendarId] = data
		// eventModel.eventsData.items = eventModel.eventsData.items.concat(eventModel.eventsByCalendar[calendarId].items)
		calendarFetched(calendarId, data)
	}

	function parseGoogleCalendarEvent(calendarId, event) {
		event.calendarId = calendarId

		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
		calendarList.forEach(function(calendar){
			if (calendarId == calendar.id) {
				event.backgroundColor = event.backgroundColor || calendar.backgroundColor
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
				data.items.forEach(function(event){
					event.backgroundColor = event.backgroundColor || calendar.backgroundColor
				})
			}
		})
	}

	function parseGCalEvents() {
		var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
		eventModel.eventsData = { items: [] }
		for (var calendarId in eventModel.eventsByCalendar) {
			parseGoogleCalendarEvents(calendarId, eventModel.eventsByCalendar[calendarId])
			eventModel.eventsData.items = eventModel.eventsData.items.concat(eventModel.eventsByCalendar[calendarId].items)
			// console.log('updateUI', calendarId, eventModel.eventsByCalendar[calendarId].items.length, eventsData.items.length);
		}
	}
	

	Timer {
		id: deferredUpdate
		interval: 200
		onTriggered: eventModel.update()
	}
	function update() {
		fetchAllEvents(dateMin, dateMax)
	}

	function fetchAllEvents(dateMin, dateMax) {
		console.log('fetchAllEvents', dateMin, dateMax)
		fetchingData()
		clear()
		eventModel.dateMin = dateMin
		eventModel.dateMax = dateMax
		fetchGoogleAccountData()
		fetchDebugEvents()
		checkIfDone()
	}

	function checkIfDone() {
		if (asyncRequestsDone >= asyncRequests) {
			allDataFetched()
		}
	}

	function fetchDebugEvents() {
		setCalendarData('debug', DebugFixtures.getEventData())
		fetchDebugGoogleSession()
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
		console.log('fetchGoogleCalendarEvents', calendarId)
		eventModel.asyncRequests += 1
		fetchGCalEvents({
			calendarId: calendarId,
			start: eventModel.dateMin.toISOString(),
			end: eventModel.dateMax.toISOString(),
			access_token: accessToken,
		}, function(err, data, xhr) {
			if (err) {
				if (typeof err === 'object') {
					console.log('err: ', JSON.stringify(err, null, '\t'));
				} else {
					console.log('err: ', err);
				}
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
		if (typeof err === 'object') {
			console.log('onGCalError: ', JSON.stringify(err, null, '\t'));
		} else {
			console.log('onGCalError: ', err);
		}
		
		deferredUpdateAccessToken.restart()
	}

	function fetchNewAccessToken(callback) {
		console.log('fetchNewAccessToken');
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
		// console.log('access_token_expires_at', plasmoid.configuration.access_token_expires_at);
		// console.log('                    now', Date.now());
		// console.log('refresh_token', plasmoid.configuration.refresh_token);
		if (plasmoid.configuration.refresh_token) {
			console.log('updateAccessToken');
			fetchNewAccessToken(function(err, data, xhr) {
				if (err || (!err && data && data.error)) {
					return console.log('Error when using refreshToken:', err, data);
				}
				console.log('onAccessToken', data);
				data = JSON.parse(data);

				plasmoid.configuration.access_token = data.access_token;
				plasmoid.configuration.access_token_type = data.token_type;
				plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000;

				deferredUpdate.restart()
			});
		}
	}

	function fetchGCalEvents(args, callback) {
		console.log('fetchGCalEvents', args.calendarId);
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
			console.log('fetchGCalEvents.response', args.calendarId, err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
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
				console.log('attempting to create an event without an access token set')
			}
		} else {
			console.log('cannot create an new event for the calendar', calendarId)
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
				// console.log(err, JSON.stringify(data, null, '\t'));
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
			console.log('patchGCalEvent.response', err, data, xhr.status);
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


	function setGoogleCalendarEventSummary(accessToken, calendarId, eventId, summary) {
		var event = getEvent(calendarId, eventId);
		if (!event) {
			console.log('error, trying to set summary for event that doesn\'t exist')
			return;
		}
		
		// Clone the event data and clean up the extra stuff we added in parseGCalEvents()
		var data = JSON.parse(JSON.stringify(event)) // clone
		console.log(JSON.stringify(data, null, '\t'))
		if (data.start.date) delete data.start.dateTime;
		if (data.end.date) delete data.end.dateTime;
		if (data.end.calendarId) delete data.end.calendarId;

		data.summary = summary
		console.log(JSON.stringify(data, null, '\t'))
		
		patchGCalEvent({
			accessToken: accessToken,
			calendarId: calendarId,
			eventId: eventId,
			// data: {
			// 	summary: summary,
			// },
			data: data,
		}, function(err, data, xhr) {
			console.log('setGoogleCalendarEventSummary.response', err, data, xhr.status);
			console.log('setGoogleCalendarEventSummary.response', JSON.stringify(data, null, '\t'))
			if (data.summary) {
				event.summary = data.summary
			}
			eventUpdated(calendarId, event)
		})
	}

	function setEventSummary(calendarId, eventId, summary) {
		setGoogleCalendarEventSummary(plasmoid.configuration.access_token, calendarId, eventId, summary)
	}
}
