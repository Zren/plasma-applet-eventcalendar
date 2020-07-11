import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "../Shared.js" as Shared
import "../lib/Async.js" as Async
import "../lib/Requests.js" as Requests

// import "./GoogleCalendarTests.js" as GoogleCalendarTests

CalendarManager {
	id: googleTasksManager

	calendarManagerId: "GoogleTasks"

	property var session
	readonly property var tasklistIdList: ['@default']

	onFetchAllCalendars: {
		fetchGoogleAccountData()
	}

	function fetchGoogleAccountData() {
		if (session.accessToken) {
			fetchGoogleAccountTasks(tasklistIdList)
		}
	}

	//-------------------------
	// CalendarManager
	function getCalendar(calendarId) {
		return {
			id: calendarId,
			backgroundColor: theme.highlightColor
		}
	}


	//-------------------------
	// Tasks
	function fetchGoogleAccountTasks(tasklistIdList) {
		googleCalendarManager.asyncRequests += 1
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
		googleCalendarManager.asyncRequestsDone += 1
		return handleError(err, data, xhr)
	}
	function fetchGoogleAccountTasks_done(results) {
		for (var i = 0; i < results.length; i++) {
			var tasklistId = results[i].tasklistId
			var tasklistData = results[i].data
			var eventList = parseTasklistAsEvents(tasklistData)
			setCalendarData(tasklistId, eventList)
		}
		googleCalendarManager.asyncRequestsDone += 1
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

		var editTasksUrl = 'https://tasks.google.com/embed/?origin=' + encodeURIComponent('https://calendar.google.com') + '&fullWidth=1'
		eventData.htmlLink = editTasksUrl

		eventData.isCompleted = taskData.status == "completed"

		if (taskData.completed) {
			var completedAt = new Date(taskData.completed)
			var startDateTime = new Date(completedAt.getFullYear(), completedAt.getMonth(), completedAt.getDate())
		} else if (taskData.due) {
			var dueDateTime = new Date(taskData.due)
			// Use local time zone, like we do in CalendarManager.onEventParsing
			eventData.dueDate = Shared.dateString(dueDateTime)
			eventData.dueDateTime = new Date(eventData.dueDate + ' 00:00:00')
			// All day event, due at end of day.
			eventData.dueEndOfDay = taskData.due.indexOf('T00:00:00.000Z') !== -1

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
			// start: googleCalendarManager.dateMin.toISOString(),
			// end: googleCalendarManager.dateMax.toISOString(),
			access_token: session.accessToken,
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
			logger.debug('fetchGCalTasksPageResponse.nextPageToken', 'allData.items.length', allData.items.length)
			args.pageToken = allData.nextPageToken
			var onResponse = fetchGCalTasksPageResponse.bind(this, args, finishedCallback, allData)
			fetchGCalTasksPage(args, onResponse)
		} else {
			logger.debug('fetchGCalTasksPageResponse.finished', 'allData.items.length', allData.items.length)
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
				"Authorization": "Bearer " + args.access_token,
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
}
