import QtQuick 2.0

import "../utils.js" as Utils
import "../shared.js" as Shared
import "../../code/ColorIdMap.js" as ColorIdMap

CalendarManager {
	id: googleCalendarManager

	calendarManagerId: "googlecal"
	property var calendarIdList: plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']

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
		var onResponse = fetchGCalEventsPageResponse.bind(this, args, callback, null)
		fetchGCalEventsPage(args, onResponse)
	}

	function inPlaceMergeArray(arr1, arr2) {
		arr1.splice.apply(arr1, [arr1.length, 0].concat(arr2))
	}

	function fetchGCalEventsPageResponse(args, finishedCallback, allData, err, data, xhr) {
		logger.debug('fetchGCalEventsPageResponse', args, finishedCallback, allData, err, data, xhr);
		if (err) {
			return finishedCallback(err, data, xhr)
		}
		if (allData) {
			// inPlaceMergeArray(allData.items, data.items) // Merge events
			// delete data.items // Delete old reference
			data.items = allData.items.concat(data.items)
			delete allData.items
			delete allData
		}
		allData = data
		
		if (allData.nextPageToken) {
			logger.debug('fetchGCalEventsPageResponse.nextPageToken', allData.nextPageToken)
			logger.debug('fetchGCalEventsPageResponse.nextPageToken', 'allData.items.length', allData.items.length)
			args.pageToken = allData.nextPageToken
			var onResponse = fetchGCalEventsPageResponse.bind(this, args, finishedCallback, allData)
			fetchGCalEventsPage(args, onResponse)
		} else {
			logger.debug('fetchGCalEventsPageResponse.finished', 'allData.items.length', allData.items.length)
			finishedCallback(err, allData, xhr)
		}
	}

	function fetchGCalEventsPage(args, pageCallback) {
		logger.debug('fetchGCalEventsPage', args.calendarId);
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events';
		url += '?timeMin=' + encodeURIComponent(args.start);
		url += '&timeMax=' + encodeURIComponent(args.end);
		url += '&singleEvents=' + encodeURIComponent('true');
		url += '&timeZone=' + encodeURIComponent('Etc/UTC');
		if (args.pageToken) {
			url += '&pageToken=' + encodeURIComponent(args.pageToken);
		}
		Utils.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.access_token,
			}
		}, function(err, data, xhr) {
			logger.debug('fetchGCalEventsPage.response', args.calendarId, err, data, xhr.status)
			if (!err && data && data.error) {
				return pageCallback(data, null, xhr);
			}
			logger.debugJSON('fetchGCalEventsPage.response', args.calendarId, data)
			pageCallback(err, data, xhr);
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
		event.canEdit = (calendar.accessRole == 'writer' || calendar.accessRole == 'owner') && !event.recurringEventId // We cannot currently edit repeating events.
		if (true && event.htmlLink) {
			// The new material website doesn't open the editor right away.
			// The htmlLink will select the event in the month view, forcing the
			// user to click the edit icon after loading the page.
			var eidRegex = /eid=(\w+)(\&|$)/
			var eidMatch = eidRegex.exec(event.htmlLink)
			var eid = eidMatch[1]
			if (eid) {
				event.htmlLink = 'https://calendar.google.com/calendar/r/eventedit/' + eid
			}
		}
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


	function cloneRawEvent(event) {
		// Clone the event data and clean up the extra stuff we added when parsing the event.
		var data = JSON.parse(JSON.stringify(event)) // clone
		if (data.start.date) delete data.start.dateTime;
		if (data.end.date) delete data.end.dateTime;
		if (data.end.calendarId) delete data.end.calendarId;
		delete data.canEdit;
		delete data._summary;
		return data;
	}

	function setGoogleCalendarEventSummary(accessToken, calendarId, eventId, summary) {
		updateGoogleCalendarEvent(accessToken, calendarId, eventId, {
			summary: summary
		})
	}

	function updateGoogleCalendarEvent(accessToken, calendarId, eventId, args) {
		var event = getEvent(calendarId, eventId);
		if (!event) {
			logger.log('error, trying to update event that doesn\'t exist')
			return;
		}
		
		// Merge assigned values into a cloned object
		var data = cloneRawEvent(event)
		var keys = Object.keys(args)
		for (var i = 0; i < keys.length; i++) {
			var key = keys[i]
			data[key] = args[keys]
		}
		logger.debugJSON('updateGoogleCalendarEvent', 'sent', data)
		
		updateGCalEvent({
			accessToken: accessToken,
			calendarId: calendarId,
			eventId: eventId,
			data: data,
		}, function(err, data, xhr) {
			logger.debugJSON('setGoogleCalendarEventSummary.response', data)

			// Merge serialized values
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				if (typeof data[key] !== "undefined") {
					event[key] = data[key]
				}
			}
			
			parseSingleEvent(calendarId, event)
			eventUpdated(calendarId, eventId, event)
		})
	}

	function updateGCalEvent(args, callback) {
		// PUT https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events/';
		url += encodeURIComponent(args.eventId);
		Utils.postJSON({
			method: 'PUT',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: args.data,
		}, function(err, data, xhr) {
			logger.debug('updateGCalEvent.response', err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
			callback(err, data, xhr);
		})
	}

	function patchGCalEvent(args, callback) {
		// Note: Qt 5.7+ still doesn't support the PATCH method type
		// https://bugreports.qt.io/browse/QTBUG-38175
		// Qt 5.8 supports it, but KDE depends on Qt 5.7 or less still so we must support it.
		// Instead, we'll use "update" with PUT.
		throw new Exception("Qt 5.7+ still doesn't support the PATCH method type")
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
