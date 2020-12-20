import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "../Shared.js" as Shared
import "../lib/Async.js" as Async
import "../lib/Requests.js" as Requests

// import "./GoogleCalendarTests.js" as GoogleCalendarTests


// Google Tasks API
// https://developers.google.com/tasks/v1/reference/tasks

// You can view Google Tasks with this URL:
// https://tasks.google.com/embed/?origin=https%3A%2F%2Fcalendar.google.com&fullWidth=1
// Note that it redirects to /embed/list/~default which you cannot bookmark, as it'll 404.

CalendarManager {
	id: googleTasksManager

	calendarManagerId: "GoogleTasks"

	property var session
	readonly property var tasklistIdList: plasmoid.configuration.tasklistIdList ? plasmoid.configuration.tasklistIdList.split(',') : []

	onFetchAllCalendars: {
		fetchGoogleAccountData()
	}

	function fetchGoogleAccountData() {
		if (session.accessToken) {
			fetchGoogleAccountTasks(tasklistIdList)
		}
	}

	//--- Utils
	function cloneRawTask(task) {
		var validProperties = [
			'kind',
			'id',
			'etag',
			'title',
			'updated',
			'selfLink',
			'parent',
			'position',
			'notes',
			'status',
			'due',
			'completed',
			'deleted',
			'hidden',
			'links',
		]
		var data = {}
		for (var i = 0; i < validProperties.length; i++) {
			var key = validProperties[i]
			var value = task[key]
			if (typeof value !== 'undefined') {
				data[key] = value
			}
		}
		return data
	}

	//-------------------------
	// CalendarManager
	function getCalendarList() {
		if (session.accessToken && plasmoid.configuration.tasklistList) {
			var tasklistList = JSON.parse(Qt.atob(plasmoid.configuration.tasklistList))
			var calendarList = []
			for (var i = 0; i < tasklistList.length; i++) {
				var tasklist = tasklistList[i]
				calendarList.push({
					id: tasklist.id,
					summary: tasklist.title,
					backgroundColor: theme.highlightColor.toString(),
					accessRole: 'owner',
					isTasklist: true,
				})
			}
			return calendarList
		} else {
			return []
		}
	}


	//-------------------------
	// Tasks
	function fetchGoogleAccountTasks(tasklistIdList) {
		googleTasksManager.asyncRequests += 1
		var func = fetchGoogleAccountTasks_run.bind(this, tasklistIdList, function(errObj, data) {
			if (errObj) {
				fetchGoogleAccountTasks_err(errObj.err, errObj.data, errObj.xhr)
			} else {
				fetchGoogleAccountTasks_done(data)
			}
		})
		session.checkAccessToken(func)
	}
	function fetchGoogleAccountTasks_run(tasklistIdList, callback) {
		logger.debug('fetchGoogleAccountTasks_run', tasklistIdList)

		var tasks = []
		for (var i = 0; i < tasklistIdList.length; i++) {
			var tasklistId = tasklistIdList[i]
			var task = fetchGoogleTasks.bind(this, tasklistId)
			tasks.push(task)
		}

		Async.parallel(tasks, callback)
	}
	function fetchGoogleAccountTasks_err(err, data, xhr) {
		logger.debug('fetchGoogleAccountTasks_err', err, data, xhr)
		googleTasksManager.asyncRequestsDone += 1
		return handleError(err, data, xhr)
	}
	function fetchGoogleAccountTasks_done(results) {
		for (var i = 0; i < results.length; i++) {
			var tasklistId = results[i].tasklistId
			var tasklistData = results[i].data
			var eventList = parseTasklistAsEvents(tasklistData)
			setCalendarData(tasklistId, eventList)
		}
		googleTasksManager.asyncRequestsDone += 1
	}

	function sortTasklist(tasklist) {
		tasklist.sort(function(a,b) {
			if (typeof a.position !== 'undefined') {
				if (typeof b.position !== 'undefined') {
					var ap = a.position
					var bp = b.position
					if (ap == bp) {
						return 0
					} else if (ap < bp) {
						return -1
					} else { // ap > bp
						return 1
					}
				} else {
					return 1
				}
			} else {
				if (typeof b.position !== 'undefined') {
					return -1
				} else {
					0
				}
			}
		})

		//--- Debug
		// for (var i = 0; i < tasklist.length; i++) {
		// 	var taskData = tasklist[i]
		// 	logger.debug('task', i, taskData.position, taskData.title)
		// }
	}

	function parseTasklistAsEvents(tasklistData) {
		var eventList = []
		for (var i = 0; i < tasklistData.items.length; i++) {
			var taskData = tasklistData.items[i]
			// logger.debugJSON('tasklistData', i, taskData)
			var eventData = parseTaskAsEventData(taskData)
			// logger.debugJSON('tasklistData', i, eventData)
			eventList.push(eventData)
		}

		// Note that AgendaModel will sort again in AgendaModel.parseGCalEvents,
		// which ruins this sorting.
		sortTasklist(eventList)

		return {
			items: eventList,
		}
	}

	function parseTaskAsEventData(taskData) {
		// Don't bother creating a new object.
		var eventData = taskData

		eventData.summary = taskData.title
		eventData.canEdit = true

		var editTasksUrl = 'https://tasks.google.com/embed/?origin=' + encodeURIComponent('https://calendar.google.com') + '&fullWidth=1'
		eventData.htmlLink = editTasksUrl

		eventData.isCompleted = taskData.status == "completed"

		if (taskData.completed) {
			var completedAt = new Date(taskData.completed)
			var startDateTime = new Date(completedAt.getFullYear(), completedAt.getMonth(), completedAt.getDate())
		} else if (taskData.due) {
			// Note: In the Google Tasks API docs:
			// The due date only records date information; the time portion of the timestamp is discarded when setting the due date.
			// It isn't possible to read or write the time that a task is due via the API.
			var dueDateTime = new Date(taskData.due)
			// Use local time zone, like we do in CalendarManager.onEventParsing
			eventData.dueDate = Shared.dateString(dueDateTime)
			eventData.dueDateTime = new Date(eventData.dueDate + ' 00:00:00')
			// All day event, due at end of day.
			eventData.dueEndOfDay = taskData.due.indexOf('T00:00:00.000Z') !== -1
			if (eventData.dueEndOfDay) {
				var dueEndTime = new Date(eventData.dueDateTime)
				dueEndTime.setDate(dueEndTime.getDate() + 1)
				eventData.dueEndTime = dueEndTime
			} else {
				eventData.dueEndTime = eventData.dueDateTime
			}
			var startDateTime = new Date(eventData.dueDateTime)
		} else {
			var today = new Date()
			var startDateTime = new Date(today.getFullYear(), today.getMonth(), today.getDate())
		}
		var endDateTime = new Date(startDateTime)
		endDateTime.setDate(endDateTime.getDate() + 1)
		eventData.start = {
			date: Shared.dateString(startDateTime),
		}
		eventData.end = {
			date: Shared.dateString(endDateTime),
		}

		if (taskData.parent) {
			// TODO: This is a subtask
		}

		return eventData
	}

	function fetchGoogleTasks(tasklistId, callback) {
		logger.debug('fetchGoogleTasks', tasklistId)
		fetchGCalTasks({
			tasklistId: tasklistId,
			// start: googleTasksManager.dateMin.toISOString(),
			// end: googleTasksManager.dateMax.toISOString(),
			accessToken: session.accessToken,
		}, function(err, data, xhr) {
			if (err) {
				logger.logJSON('onErrorFetchingTasks: ', err)
				var errObj = {
					err: err,
					data: data,
					xhr: xhr,
				}
				return callback(errObj, null)
			}

			return callback(null, {
				tasklistId: tasklistId,
				data: data,
			})
		})
	}

	function fetchGCalTasks(args, callback) {
		logger.debug('fetchGCalTasks', args.tasklistId)

		// return GoogleCalendarTests.testInvalidCredentials(callback)
		// return GoogleCalendarTests.testDailyLimitExceeded(callback)
		// return GoogleCalendarTests.testBackendError(callback)

		var onResponse = fetchGCalTasksPageResponse.bind(this, args, callback, null)
		fetchGCalTasksPage(args, onResponse)
	}

	function fetchGCalTasksPageResponse(args, finishedCallback, allData, err, data, xhr) {
		logger.debug('fetchGCalTasksPageResponse', args, finishedCallback, allData, err, data, xhr)
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
			logger.debug('fetchGCalTasksPageResponse.nextPageToken', allData.nextPageToken)
			logger.debug('fetchGCalTasksPageResponse.nextPageToken', 'allData.items.length', allData.items && allData.items.length)
			args.pageToken = allData.nextPageToken
			var onResponse = fetchGCalTasksPageResponse.bind(this, args, finishedCallback, allData)
			fetchGCalTasksPage(args, onResponse)
		} else {
			logger.debug('fetchGCalTasksPageResponse.finished', 'allData.items.length', allData.items && allData.items.length)
			finishedCallback(err, allData, xhr)
		}
	}

	function fetchGCalTasksPage(args, pageCallback) {
		logger.debug('fetchGCalTasksPage', args.tasklistId)
		var url = 'https://www.googleapis.com/tasks/v1'
		url += '/lists/'
		url += encodeURIComponent(args.tasklistId)
		url += '/tasks'
		url += '?showCompleted=true'
		url += '&showHidden=true'
		// url += '&dueMin=' + encodeURIComponent(args.start)
		// url += '&dueMax=' + encodeURIComponent(args.end)
		if (args.pageToken) {
			url += '&pageToken=' + encodeURIComponent(args.pageToken)
		}
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			}
		}, function(err, data, xhr) {
			logger.debug('fetchGCalTasksPage.response', args.tasklistId, err, data, xhr.status)
			if (!err && data && data.error) {
				return pageCallback(data, null, xhr)
			}
			// logger.debugJSON('fetchGCalTasksPage.response', args.tasklistId, data)
			pageCallback(err, data, xhr)
		})
	}


	//--- Create / POST
	function createEvent(calendarId, date, text) {
		if (session.accessToken) {
			var eventText = text

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
		createGoogleTask({
			accessToken: session.accessToken,
			tasklistId: calendarId,
			title: eventText,
		}, callback)
	}
	function createEvent_done(calendarId, data) {
		logger.debugJSON(calendarManagerId, 'createEvent_done', calendarId, data)
		if (googleTasksManager.tasklistIdList.indexOf(calendarId) >= 0) {
			var eventData = parseTaskAsEventData(data)
			parseSingleEvent(calendarId, eventData)
			addEvent(calendarId, eventData)
			eventCreated(calendarId, eventData)
		}
	}
	function createEvent_err(err, data, xhr) {
		logger.log(calendarManagerId, 'createEvent_err', err, data, xhr)
		return handleError(err, data, xhr)
	}

	function createGoogleTask(args, callback) {
		// https://www.googleapis.com/tasks/v1/lists/tasklistId/tasks
		var url = 'https://www.googleapis.com/tasks/v1'
		url += '/lists/'
		url += encodeURIComponent(args.tasklistId)
		url += '/tasks'
		var taskData = {
			title: args.title,
			// notes: args.notes,
			// due: args.due,
		}
		Requests.postJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: taskData,
		}, function(err, data, xhr) {
			console.log('createGoogleTask.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}


	//--- Delete Task
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

		deleteGoogleTask({
			accessToken: session.accessToken,
			tasklistId: calendarId,
			taskId: eventId,
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

	function deleteGoogleTask(args, callback) {
		// DELETE https://www.googleapis.com/tasks/v1/lists/tasklistId/tasks/taskId
		// Note: Success means a response of xhr.status == 204 (No Content)
		var url = 'https://www.googleapis.com/tasks/v1'
		url += '/lists/'
		url += encodeURIComponent(args.tasklistId)
		url += '/tasks/'
		url += encodeURIComponent(args.taskId)
		Requests.postJSON({
			method: 'DELETE',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
		}, function(err, data, xhr) {
			logger.debug('deleteGoogleTask.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}

	//--- Update Task
	function setEventProperty(calendarId, eventId, key, value) {
		logger.log(calendarManagerId, 'setEventProperty', calendarId, eventId, key, value)
		var args = {}
		args[key] = value
		setEventProperties(calendarId, eventId, args)
	}

	function setEventProperties(calendarId, eventId, args) {
		logger.logJSON(calendarManagerId, 'setEventProperties', calendarId, eventId, args)
		if (session.accessToken) {
			var event = getEvent(calendarId, eventId)
			if (!event) {
				session.transactionError('attempting to "set an event property" for an event that doesn\'t exist')
				return
			}

			var func = setEventProperties_run.bind(this, calendarId, eventId, event, args, function(err, data, xhr) {
				if (err) {
					setEventProperties_err(err, data, xhr)
				} else {
					setEventProperties_done(calendarId, eventId, event, data)
				}
			})
			session.checkAccessToken(func)
		} else {
			session.transactionError('attempting to "set an event property" without an access token set')
		}
	}
	function setEventProperties_run(calendarId, eventId, event, args, callback) {
		logger.debugJSON(calendarManagerId, 'setEventProperties_run', calendarId, eventId, event, args)
		
		// Merge assigned values into a cloned object
		var data = cloneRawTask(event)
		Shared.merge(data, args)
		logger.debugJSON(calendarManagerId, 'setEventProperties', 'sent', data)

		updateGoogleTask({
			accessToken: session.accessToken,
			tasklistId: calendarId,
			taskId: eventId,
			data: data,
		}, callback)
	}
	function setEventProperties_done(calendarId, eventId, event, data) {
		logger.debugJSON(calendarManagerId, 'setEventProperties_done', calendarId, data)

		// Merge serialized values
		var eventData = parseTaskAsEventData(data)
		Shared.merge(event, eventData)
		Shared.removeMissingKeys(event, eventData)

		parseSingleEvent(calendarId, event)
		eventUpdated(calendarId, eventId, event)
	}
	function setEventProperties_err(err, data, xhr) {
		logger.log(calendarManagerId, 'setEventProperties_err', err, data, xhr)
		return handleError(err, data, xhr)
	}

	function updateGoogleTask(args, callback) {
		// PUT https://www.googleapis.com/tasks/v1/lists/tasklistId/tasks/taskId
		var url = 'https://www.googleapis.com/tasks/v1'
		url += '/lists/'
		url += encodeURIComponent(args.tasklistId)
		url += '/tasks/'
		url += encodeURIComponent(args.taskId)
		Requests.postJSON({
			method: 'PUT',
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			},
			data: args.data,
		}, function(err, data, xhr) {
			logger.debug('updateGoogleTask.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback(data, null, xhr)
			}
			callback(err, data, xhr)
		})
	}
}
