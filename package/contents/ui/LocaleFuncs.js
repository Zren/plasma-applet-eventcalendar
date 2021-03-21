.import "Shared.js" as Shared

function formatEventTime(dateTime, args) {
	var clock24h = args && args.clock24h
	var timeFormat
	if (clock24h) {
		if (dateTime.getMinutes() === 0) {
			timeFormat = i18nc("event time on the hour (24 hour clock)", "h")
		} else {
			timeFormat = i18nc("event time (24 hour clock)", "h:mm")
		}
	} else { // 12h
		if (dateTime.getMinutes() === 0) {
			timeFormat = i18nc("event time on the hour (12 hour clock)", "h AP")
		} else {
			timeFormat = i18nc("event time (12 hour clock)", "h:mm AP")
		}
	}
	return Qt.formatDateTime(dateTime, timeFormat)
}

function formatEventDateTime(dateTime, args) {
	var shortDateFormat = i18nc("short month+date format", "MMM d")
	var dateStr = Qt.formatDateTime(dateTime, shortDateFormat)
	var timeStr = formatEventTime(dateTime, args)
	return i18nc("date (%1) with time (%2)", "%1, %2", dateStr, timeStr)
}

function formatEventDuration(event, args) {
	var relativeDate = args && args.relativeDate
	var clock24h = args && args.clock24h
	var startTime = event.startDateTime
	var endTime = event.endDateTime
	var shortDateFormat = i18nc("short month+date format", "MMM d")

	if (event.start.date) {
		// GCal ends all day events at midnight, which is technically the next day.
		// Humans consider the event to end at 23:59 the day before though.
		var dayBefore = new Date(endTime)
		dayBefore.setDate(dayBefore.getDate() - 1)
		if (Shared.isSameDate(startTime, dayBefore)) {
			return i18n("All Day")
		} else {
			var startStr = Qt.formatDateTime(startTime, shortDateFormat)
			var endStr = Qt.formatDateTime(dayBefore, shortDateFormat)
			return i18nc("from date/time %1 until date/time %2", "%1 - %2", startStr, endStr)
		}
	} else {
		var startStr
		if (!relativeDate || !Shared.isSameDate(startTime, relativeDate)) {
			startStr = formatEventDateTime(startTime, args) // MMM d, h:mm AP
		} else {
			startStr = formatEventTime(startTime, args) // h:mm AP
		}

		if (startTime.valueOf() === endTime.valueOf()) {
			return startStr // Don't need the end time
		}

		var endStr
		if (Shared.isSameDate(startTime, endTime)) {
			endStr = formatEventTime(endTime, args) // MMM d, h:mm AP - h:mm AP
		} else {
			// !isSameDate, so we need to add the date
			endStr = formatEventDateTime(endTime, args) // MMM d, h:mm AP - MMM d, h:mm AP
		}
		return i18nc("from date/time %1 until date/time %2", "%1 - %2", startStr, endStr)
	}
}

function getHours(t) {
	var hours = Math.floor(t / (60 * 60 * 1000))
	return hours
}
function getMinutes(t) {
	var millisLeftInHour = t % (60 * 60 * 1000)
	var minutes = millisLeftInHour / (60 * 1000)
	return minutes
}
function getSeconds(t) {
	var millisLeftInMinute = t % (60 * 1000)
	var seconds = millisLeftInMinute / 1000
	return seconds
}
function durationShortFormat(nSeconds) {
	var t = nSeconds * 1000
	var str = ''
	var hours = Math.floor(getHours(t))
	if (hours > 0) {
		str += i18nc("short form for %1 hours", "%1h", hours)
	}
	var minutes = Math.floor(getMinutes(t))
	if (minutes > 0) {
		str += i18nc("short form for %1 minutes", "%1m", minutes)
	}
	var seconds = Math.floor(getSeconds(t))
	if (seconds > 0) {
		str += i18nc("short form for %1 seconds", "%1s", seconds)
	}
	return str
}
