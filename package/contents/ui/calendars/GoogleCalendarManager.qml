import QtQuick 2.0

import "../ErrorType.js" as ErrorType
import "../Shared.js" as Shared
import "../lib/Async.js" as Async
import "../lib/Requests.js" as Requests
import "../../code/ColorIdMap.js" as ColorIdMap

// import "./GoogleCalendarTests.js" as GoogleCalendarTests

CalendarManager {
	id: googleCalendarManager

	calendarManagerId: "GoogleCalendar"

	property var session
	readonly property var calendarIdList: plasmoid.configuration.calendarIdList ? plasmoid.configuration.calendarIdList.split(',') : []

	onFetchAllCalendars: {
		fetchGoogleAccountData()
	}

	function fetchGoogleAccountData() {
		if (session.accessToken) {
			fetchGoogleAccountEvents(calendarIdList)
		}
	}

	//-------------------------
	// Events

	//--- Errors
	function showHttpError(httpCode, msg, suggestion, errorType) {
		var errorMessage = i18n("HTTP Error %1: %2", httpCode, msg)
		if (suggestion) {
			errorMessage += '\n' + suggestion
		}
		googleCalendarManager.error(errorMessage, errorType)
	}
	function handleError(err, data, xhr) {
		var httpCode = xhr.status
		if (httpCode === 0) {
			var msg = i18n("Could not connect")
			var suggestion = i18n("Will try again soon.")
			showHttpError(httpCode, msg, suggestion, ErrorType.NetworkError)
			return
		}

		// https://developers.google.com/calendar/v3/errors
		if (err.error && err.error.errors && err.error.errors.length >= 1) {
			httpCode = err.error.code
			var err0 = err.error.errors[0]

			if (httpCode === 401 && err0.reason == 'authError') {
				var suggestion = i18n("Widget has been updated. Please logout and login to Google Calendar again.")
				showHttpError(httpCode, err0.message, suggestion, ErrorType.ClientError)
			} else if (httpCode === 403 && err0.domain == 'usageLimits') {
				var suggestion = i18n("Too many web requests. Will try again soon.")
				showHttpError(httpCode, err0.message, suggestion, ErrorType.ClientError)
			} else {
				var suggestion = i18n("Will try again soon.")
				showHttpError(httpCode, err0.message, suggestion, ErrorType.UnknownError)
			}
			return
		}
	}


	//--- Utils
	function cloneRawEvent(event) {
		// Clone the event data and clean up the extra stuff we added when parsing the event.
		var data = JSON.parse(JSON.stringify(event)) // clone
		if (data.description == "") delete data.description
		if (data.calendarManagerId) delete data.calendarManagerId
		if (data.calendarId) delete data.calendarId
		delete data.startDateTime
		delete data.endDateTime
		delete data.canEdit
		delete data._summary
		return data
	}


	//--- List Events
	function fetchGoogleAccountEvents(calendarIdList) {
		googleCalendarManager.asyncRequests += 1
		var func = fetchGoogleAccountEvents_run.bind(this, calendarIdList, function(errObj, data) {
			if (errObj) {
				fetchGoogleAccountEvents_err(errObj.err, errObj.data, errObj.xhr)
			} else {
				fetchGoogleAccountEvents_done(data)
			}
		})
		session.checkAccessToken(func)
	}
	function fetchGoogleAccountEvents_run(calendarIdList, callback) {
		logger.debug('fetchGoogleAccountEvents_run', calendarIdList)

		var tasks = []
		for (var i = 0; i < calendarIdList.length; i++) {
			var calendarId = calendarIdList[i]
			var task = fetchGoogleCalendarEvents.bind(this, calendarId)
			tasks.push(task)
		}

		Async.parallel(tasks, callback)
	}
	function fetchGoogleAccountEvents_err(err, data, xhr) {
		logger.debug('fetchGoogleAccountEvents_err', err, data, xhr)
		googleCalendarManager.asyncRequestsDone += 1
		return handleError(err, data, xhr)
	}
	function fetchGoogleAccountEvents_done(results) {
		for (var i = 0; i < results.length; i++) {
			var calendarId = results[i].calendarId
			var calendarData = results[i].data
			setCalendarData(calendarId, calendarData)
		}
		googleCalendarManager.asyncRequestsDone += 1
	}

	function fetchGoogleCalendarEvents(calendarId, callback) {
		logger.debug('fetchGoogleCalendarEvents', calendarId)
		fetchGCalEvents({
			calendarId: calendarId,
			start: googleCalendarManager.dateMin.toISOString(),
			end: googleCalendarManager.dateMax.toISOString(),
			accessToken: session.accessToken,
		}, function(err, data, xhr) {
			if (err) {
				logger.logJSON('onErrorFetchingEvents: ', err)
				var errObj = {
					err: err,
					data: data,
					xhr: xhr,
				}
				return callback(errObj, null)
			}

			return callback(null, {
				calendarId: calendarId,
				data: data,
			})
		})
	}

	function fetchGCalEvents(args, callback) {
		logger.debug('fetchGCalEvents', args.calendarId)

		// return GoogleCalendarTests.testCouldNotConnect(callback)
		// return GoogleCalendarTests.testInvalidCredentials(callback)
		// return GoogleCalendarTests.testDailyLimitExceeded(callback)
		// return GoogleCalendarTests.testBackendError(callback)

		var onResponse = fetchGCalEventsPageResponse.bind(this, args, callback, null)
		fetchGCalEventsPage(args, onResponse)
	}

	function fetchGCalEventsPageResponse(args, finishedCallback, allData, err, data, xhr) {
		logger.debug('fetchGCalEventsPageResponse', args, finishedCallback, allData, err, data, xhr)
		if (err) {
			return finishedCallback(err, data, xhr)
		}
		if (allData) {
			data.items = allData.items.concat(data.items)
			delete allData.items
			delete allData
		}
		allData = data
		
		if (allData.nextPageToken) {
			logger.debug('fetchGCalEventsPageResponse.nextPageToken', allData.nextPageToken)
			logger.debug('fetchGCalEventsPageResponse.nextPageToken', 'allData.items.length', allData.items && allData.items.length)
			args.pageToken = allData.nextPageToken
			var onResponse = fetchGCalEventsPageResponse.bind(this, args, finishedCallback, allData)
			fetchGCalEventsPage(args, onResponse)
		} else {
			logger.debug('fetchGCalEventsPageResponse.finished', 'allData.items.length', allData.items && allData.items.length)
			finishedCallback(err, allData, xhr)
		}
	}

	function fetchGCalEventsPage(args, pageCallback) {
		logger.debug('fetchGCalEventsPage', args.calendarId)
		var url = 'https://www.googleapis.com/calendar/v3'
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId)
		url += '/events'
		url += '?timeMin=' + encodeURIComponent(args.start)
		url += '&timeMax=' + encodeURIComponent(args.end)
		url += '&singleEvents=' + encodeURIComponent('true')
		url += '&timeZone=' + encodeURIComponent('Etc/UTC')
		if (args.pageToken) {
			url += '&pageToken=' + encodeURIComponent(args.pageToken)
		}
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			}
		}, function(err, data, xhr) {
			logger.debug('fetchGCalEventsPage.response', args.calendarId, err, data, xhr.status)
			if (!err && data && data.error) {
				return pageCallback(data, null, xhr)
			}
			// logger.debugJSON('fetchGCalEventsPage.response', args.calendarId, data)
			pageCallback(err, data, xhr)
		})
	}

	//--- Get Single Event
	function fetchGoogleCalendarEvent(calendarId, eventId, callback) {
		logger.debug('fetchGoogleCalendarEvent', calendarId, eventId)
		if (session.accessToken) {
			var func = fetchGoogleCalendarEvent_run.bind(this, calendarId, eventId, callback)
			session.checkAccessToken(func)
		} else {
			session.transactionError('attempting to "fetch an event" without an access token set')
		}
	}
	function fetchGoogleCalendarEvent_run(calendarId, eventId, callback) {
		logger.debugJSON('fetchGoogleCalendarEvent_run', calendarId, eventId)
		fetchGCalEvent({
			accessToken: session.accessToken,
			calendarId: calendarId,
			eventId: eventId,
		}, callback)
	}
	function fetchGCalEvent(args, callback) {
		logger.debug('fetchGCalEvent', args.calendarId, args.eventId)

		var url = 'https://www.googleapis.com/calendar/v3'
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId)
		url += '/events/'
		url += encodeURIComponent(args.eventId)
		url += '?timeZone=' + encodeURIComponent('Etc/UTC')
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			}
		}, function(err, data, xhr) {
			logger.debug('fetchGCalEvent.response', args.calendarId, args.eventId, err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			logger.debugJSON('\t data:', data)
			callback(err, data, xhr)
		})
	}

	//--- Parsing Events
	onCalendarParsing: {
		var calendar = getCalendar(calendarId)
		data.items.forEach(function(event){
			parseEvent(calendar, event)
		})
	}

	function parseEvent(calendar, event) {
		event.description = event.description || ""
		event.backgroundColor = parseColor(calendar, event)
		event.canEdit = (calendar.accessRole == 'writer' || calendar.accessRole == 'owner') && !event.recurringEventId // We cannot currently edit repeating events.
		if (true && event.htmlLink) {
			// The new material website doesn't open the editor right away.
			// The htmlLink will select the event in the month view, forcing the
			// user to click the edit icon after loading the page.
			var eidRegex = /eid=(\w+)(\&|$)/
			var eidMatch = eidRegex.exec(event.htmlLink)
			if (eidMatch) {
				var eid = eidMatch[1]
				if (eid) {
					event.htmlLink = 'https://calendar.google.com/calendar/r/eventedit/' + eid
				}
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


	//--- Create / POST
	function createEvent(calendarId, date, text) {
		if (session.accessToken) {
			var dateString = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate()
			var eventText = dateString + ' ' + text

			var func = createEvent_run.bind(this, calendarId, eventText, function(err, data, xhr) {
				if (err) {
					createEvent_err(err, data, xhr)
				} else {
					createEvent_done(calendarId, data)
				}
			})
			session.checkAccessToken(func)
		} else {
			session.transactionError('attempting to "create an event" without an access token set')
		}
	}
	function createEvent_run(calendarId, eventText, callback) {
		logger.debugJSON(calendarManagerId, 'createEvent_run', calendarId, eventText)
		createGCalEvent({
			accessToken: session.accessToken,
			calendarId: calendarId,
			text: eventText,
		}, callback)
	}
	function createEvent_done(calendarId, data) {
		logger.debugJSON(calendarManagerId, 'createEvent_done', calendarId, data)
		if (googleCalendarManager.calendarIdList.indexOf(calendarId) >= 0) {
			parseSingleEvent(calendarId, data)
			addEvent(calendarId, data)
			eventCreated(calendarId, data)
		}
	}
	function createEvent_err(err, data, xhr) {
		logger.log(calendarManagerId, 'createEvent_err', err, data, xhr)
		return handleError(err, data, xhr)
	}

	function createGCalEvent(args, callback) {
		// https://www.googleapis.com/calendar/v3/calendars/calendarId/events/quickAdd
		var url = 'https://www.googleapis.com/calendar/v3'
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId)
		url += '/events/quickAdd'
		url += '?text=' + encodeURIComponent(args.text)
		Requests.postJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: "",
		}, function(err, data, xhr) {
			console.log('createGCalEvent.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}

	//--- Update Event
	function setEventProperty(calendarId, eventId, key, value) {
		logger.log(calendarManagerId, 'setEventProperty', calendarId, eventId, key, value)
		var args = {}
		args[key] = value
		setEventProperties(calendarId, eventId, args)
	}

	function setEventProperties(calendarId, eventId, args) {
		logger.logJSON(calendarManagerId, 'setEventProperties', calendarId, eventId, args)
		updateGoogleCalendarEvent(calendarId, eventId, args)

		// Note: Make sure switching between all day event (event.start.date) and a date+time
		// event (event.start.dateTime) works properly before switching to PATCH.
		// patchGoogleCalendarEvent(calendarId, eventId, args, callback)
	}

	function updateGoogleCalendarEvent(calendarId, eventId, args) {
		if (session.accessToken) {
			var event = getEvent(calendarId, eventId)
			if (!event) {
				session.transactionError('attempting to "set an event property" for an event that doesn\'t exist')
				return
			}

			var func = updateGoogleCalendarEvent_run.bind(this, calendarId, eventId, event, args, function(err, data, xhr) {
				if (err) {
					updateGoogleCalendarEvent_err(err, data, xhr)
				} else {
					updateGoogleCalendarEvent_done(calendarId, eventId, event, data)
				}
			})
			session.checkAccessToken(func)
		} else {
			session.transactionError('attempting to "set an event property" without an access token set')
		}
	}
	function updateGoogleCalendarEvent_run(calendarId, eventId, event, args, callback) {
		logger.debugJSON('updateGoogleCalendarEvent_run', calendarId, eventId, event, args)

		// Merge assigned values into a cloned object
		var data = cloneRawEvent(event)
		Shared.merge(data, args)
		logger.debugJSON('updateGoogleCalendarEvent', 'sent', data)

		updateGCalEvent({
			accessToken: session.accessToken,
			calendarId: calendarId,
			eventId: eventId,
			data: data,
		}, callback)
	}
	function updateGoogleCalendarEvent_done(calendarId, eventId, event, data) {
		logger.debugJSON('updateGoogleCalendarEvent_done', calendarId, data)

		// Merge serialized values
		Shared.merge(event, data)

		parseSingleEvent(calendarId, event)
		eventUpdated(calendarId, eventId, event)
	}
	function updateGoogleCalendarEvent_err(err, data, xhr) {
		logger.log('updateGoogleCalendarEvent_err', err, data, xhr)
		return handleError(err, data, xhr)
	}

	function updateGCalEvent(args, callback) {
		// PUT https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		var url = 'https://www.googleapis.com/calendar/v3'
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId)
		url += '/events/'
		url += encodeURIComponent(args.eventId)
		Requests.postJSON({
			method: 'PUT',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: args.data,
		}, function(err, data, xhr) {
			logger.debug('updateGCalEvent.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}

	function patchGoogleCalendarEvent(calendarId, eventId, eventProps, callback) {
		logger.debugJSON('patchGoogleCalendarEvent.sent', eventProps)
		
		patchGCalEvent({
			accessToken: session.accessToken,
			calendarId: calendarId,
			eventId: eventId,
			data: eventProps,
		}, function(err, data, xhr) {
			logger.debugJSON('patchGoogleCalendarEvent.response', err, data)
			
			parseSingleEvent(calendarId, data)
			eventUpdated(calendarId, eventId, data)
			callback(err, data, xhr)
		})
	}

	function patchGCalEvent(args, callback) {
		// Requires Qt 5.8 (Plasma 5.12 depends on Qt 5.9)
		// Note: Qt 5.7 and below doesn't support the PATCH method type.
		// https://bugreports.qt.io/browse/QTBUG-38175

		// Even though Qt 5.10's qmlscene can send a PATCH request with a body,
		// plasmashell + plasmoidviewer is doing something weird, as while both
		// send the PATCH request to the server, it does not send the body.
		// Demo: https://gist.github.com/Zren/3cdee1cd6fce144c234cdca9d3f32fc1
		throw new Exception("plasmashell with Qt 5.10 still doesn't fully support the PATCH method type")

		// var url = 'https://www.googleapis.com/calendar/v3'
		// url += '/calendars/'
		// url += encodeURIComponent(args.calendarId)
		// url += '/events/'
		// url += encodeURIComponent(args.eventId)
		// Requests.postJSON({
		// 	method: 'PATCH',
		// 	url: url,
		// 	headers: {
		// 		"Authorization": "Bearer " + args.accessToken,
		// 	},
		// 	data: args.data,
		// }, function(err, data, xhr) {
		// 	logger.debug('patchGCalEvent.response', err, data, xhr.status)
		// 	if (!err && data && data.error) {
		// 		return callback(data, null, xhr)
		// 	}
		// 	callback(err, data, xhr)
		// })
	}

	//--- Delete Event
	function deleteEvent(calendarId, eventId) {
		logger.log(calendarManagerId, 'deleteEvent', calendarId, eventId)
		if (session.accessToken) {
			var event = getEvent(calendarId, eventId)
			if (!event) {
				session.transactionError('attempting to "delete an event" for an event that doesn\'t exist')
				return
			}

			var func = deleteEvent_run.bind(this, calendarId, eventId, function(err, data, xhr) {
				if (err) {
					deleteEvent_err(err, data, xhr)
				} else {
					deleteEvent_done(calendarId, eventId, data)
				}
			})
			session.checkAccessToken(func)
		} else {
			session.transactionError('attempting to "delete an event" without an access token set')
		}
	}
	function deleteEvent_run(calendarId, eventId, callback) {
		logger.debugJSON(calendarManagerId, 'deleteEvent_run', calendarId, eventId)

		deleteGCalEvent({
			accessToken: session.accessToken,
			calendarId: calendarId,
			eventId: eventId,
		}, callback)
	}
	function deleteEvent_done(calendarId, eventId, data) {
		logger.debugJSON(calendarManagerId, 'deleteEvent_done', calendarId, eventId, data)

		// Note: No data is returned on success
		var event = getEvent(calendarId, eventId)
		if (event) {
			removeEvent(calendarId, eventId)
			eventDeleted(calendarId, eventId, event)
		}
	}
	function deleteEvent_err(err, data, xhr) {
		logger.log(calendarManagerId, 'deleteEvent_err', err, data, xhr)
		return handleError(err, data, xhr)
	}

	function deleteGCalEvent(args, callback) {
		// DELETE https://www.googleapis.com/calendar/v3/calendars/calendarId/events/eventId
		// Note: Success means a response of xhr.status == 204 (No Content)
		var url = 'https://www.googleapis.com/calendar/v3'
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId)
		url += '/events/'
		url += encodeURIComponent(args.eventId)
		Requests.postJSON({
			method: 'DELETE',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
		}, function(err, data, xhr) {
			logger.debug('deleteGCalEvent.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}

	//--- CalendarManager
	function getCalendarList() {
		if (session.accessToken && plasmoid.configuration.calendarList) {
			var calendarList = JSON.parse(Qt.atob(plasmoid.configuration.calendarList))
			for (var i = 0; i < calendarList.length; i++) {
				var calendar = calendarList[i]
				calendar.isTasklist = false
			}
			return calendarList
		} else {
			return []
		}
	}

	function getCalendar(calendarId) {
		var calendarList = getCalendarList()
		for (var i = 0; i < calendarList.length; i++) {
			var calendar = calendarList[i]
			if (calendarId == calendar.id || (calendarId == 'primary' && calendar.primary)) {
				return calendar
			}
		}
		return null
	}
}
