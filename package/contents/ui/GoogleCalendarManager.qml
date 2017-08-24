import QtQuick 2.0

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/ColorIdMap.js" as ColorIdMap

CalendarManager {
	id: googleCalendarManager

	property variant calendarIdList: plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']

	onFetchAllCalendars: {
		fetchGoogleAccountData()
	}

	function fetchGoogleAccountData() {
		if (plasmoid.configuration.access_token) {
			fetchGoogleAccountEvents(plasmoid.configuration.access_token, calendarIdList)
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
		googleCalendarManager.asyncRequests += 1
		fetchGCalEvents({
			calendarId: calendarId,
			start: googleCalendarManager.dateMin.toISOString(),
			end: googleCalendarManager.dateMax.toISOString(),
			access_token: accessToken,
		}, function(err, data, xhr) {
			if (err) {
				logger.logJSON('onGCalError: ', err);
				if (xhr.status === 404) {
					return;
				}
				googleCalendarManager.asyncRequestsDone += 1
				return onGCalError(err);
			}

			setCalendarData(calendarId, data)
			googleCalendarManager.asyncRequestsDone += 1
		});
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

	function onGCalError(err) {
		logger.logJSON('onGCalError: ', err);
		deferredUpdateAccessToken.restart()
	}







	Timer {
		id: deferredUpdateAccessToken
		interval: 200
		onTriggered: updateAccessToken()
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

	onCalendarParsing: {
		var calendar = getCalendar(calendarId)
		data.items.forEach(function(event){
			parseEvent(calendar, event)
		})
	}

	function parseEvent(calendar, event) {
		event.backgroundColor = parseColor(calendar, event)
		event.canEdit = calendar.accessRole == 'owner' && !event.recurringEventId // We cannot currently edit repeating events.
	}

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
				if (googleCalendarManager.calendarIdList.indexOf(calendarId) >= 0) {
					parseSingleEvent(calendarId, data)
					addEvent(calendarId, data)
					eventCreated(calendarId, data)
				}
			})
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
			parseSingleEvent(calendarId, event)
			eventUpdated(calendarId, eventId, event)
		})
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
		if (plasmoid.configuration.access_token) {
			deleteGCalEvent({
				accessToken: plasmoid.configuration.access_token,
				calendarId: calendarId,
				eventId: eventId,
			}, function(err, data, xhr) {
				// Note: No data is returned on success
				// logger.debugJSON('deleteEvent.response', err, data, xhr.status)
				var event = getEvent(calendarId, eventId)
				logger.debugJSON('deleteEvent.success', calendarId, eventId, event)
				if (event) {
					removeEvent(calendarId, eventId)
					eventDeleted(calendarId, eventId, event)
				}
			})
		} else {
			logger.log('attempting to delete an event without an access token set')
		}
	}

	function deleteGCalEvent(args, callback) {
		// DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		// Note: Success means a response of xhr.status == 204 (No Content)
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
