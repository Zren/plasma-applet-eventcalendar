import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

CalendarManager {
	id: icalManager

	// property variant eventsData: { "items": [] }

	property var calendarList: [
		{
			url: "/home/chris/Code/icsjson/basic.ics",
			backgroundColor: '#ff0',
		}
	]

	function getCalendar(calendarId) {
		for (var i = 0; i < calendarList.length; i++) {
			var calendarData = calendarList[i]
			if (calendarData.url == calendarId) {
				return calendarData
			}
		}
		return null
	}

	PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: {
			var exitCode = data["exit code"]
			var exitStatus = data["exit status"]
			var stdout = data["stdout"]
			var stderr = data["stderr"]
			exited(sourceName, exitCode, exitStatus, stdout, stderr)
			disconnectSource(sourceName) // cmd finished
		}

		signal exited(string cmd, int exitCode, int exitStatus, string stdout, string stderr)

		function trimOutput(stdout) {
			return stdout.replace('\n', ' ').trim()
		}

		property var listeners: { return {} }

		function exec(cmd, callback) {
			if (typeof callback === 'function') {
				if (listeners[cmd]) { // Our implementation only allows 1 callback per command.
					exited.disconnect(listeners[cmd])
					delete listeners[cmd]
				}
				var listener = execCallback.bind(executable, callback)
				exited.connect(listener)
				listeners[cmd] = listener
			}
			connectSource(cmd)
		}

		function execCallback(callback, cmd, exitCode, exitStatus, stdout, stderr) {
			exited.disconnect(listeners[cmd])
			delete listeners[cmd]
			callback(cmd, exitCode, exitStatus, stdout, stderr)
		}
	}

	function fetchEvents(calendarData, startTime, endTime, callback) {
		console.log('fetchEvents', calendarData.url)
		var cmd = 'python3 /home/chris/Code/icsjson/icsjson.py'
		cmd += ' --file "' + calendarData.url + '"' // TODO proper argument wrapping
		cmd += ' query'
		cmd += ' ' + startTime.getFullYear() + '-' + (startTime.getMonth()+1) + '-' + startTime.getDate()
		cmd += ' ' + endTime.getFullYear() + '-' + (endTime.getMonth()+1) + '-' + endTime.getDate()
		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			if (exitCode) {
				console.log(stderr)
				return callback(stderr)
			}
			var data = JSON.parse(stdout)
			// console.log(cmd)
			// console.log(str)
			callback(null, data)
		})
	}

	function fetchCalendar(calendarData) {
		icalManager.asyncRequests += 0
		fetchEvents(calendarData, dateMin, dateMax, function(err, data) {
			parseEventList(calendarData, data.items)
			setCalendarData(calendarData.url, data)
			icalManager.asyncRequestsDone += 1
		})
	}

	onFetchAllCalendars: {
		for (var i = 0; i < calendarList.length; i++) {
			var calendarData = calendarList[i]
			fetchCalendar(calendarData)
		}
	}

	function parseEvent(calendar, event) {
		event.backgroundColor = calendar.backgroundColor
		event.canEdit = false
		event._summary = event.summary
		event.summary = event.summary || i18nc("event with no summary", "(No title)")
	}

	function parseEventList(calendar, eventList) {
		eventList.forEach(function(event) {
			parseEvent(calendar, event)
		})
	}

	// onCalendarFetched: {
	// 	console.log(calendarId, data)
	// }

	// Component.onCompleted: {
	// 	var startTime = new Date(2017, 07-1, 01)
	// 	var endTime = new Date(2017, 07-1, 31)
	// 	dateMin = startTime
	// 	dateMax = endTime
	// 	fetchAllCalendars()
	// }
}
