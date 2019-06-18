.pragma library

.import "./lib/Requests.js" as Requests

function openGoogleCalendarNewEventUrl(date) {
	function dateString(year, month, day) {
		var s = '' + year
		s += (month < 10 ? '0' : '') + month
		s += (day < 10 ? '0' : '') + day
		return s
	}

	var nextDay = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)

	var url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
	var startDate = dateString(date.getFullYear(), date.getMonth() + 1, date.getDate())
	var endDate = dateString(nextDay.getFullYear(), nextDay.getMonth() + 1, nextDay.getDate())
	url += '&dates=' + startDate + '/' + endDate
	Qt.openUrlExternally(url)
}

function isSameDate(a, b) {
	// console.log('isSameDate', a, b)
	return a.getFullYear() == b.getFullYear() && a.getMonth() == b.getMonth() && a.getDate() == b.getDate()
}
function isDateEarlier(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()) // midnight of date b
	return a < c
}
function isDateAfter(a, b) {
	var c = new Date(b.getFullYear(), b.getMonth(), b.getDate() + 1) // midnight of next day after b
	return a >= c
}
