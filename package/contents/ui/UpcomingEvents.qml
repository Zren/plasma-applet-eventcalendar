import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "LocaleFuncs.js" as LocaleFuncs
import "./calendars"

CalendarManager {
	id: upcomingEvents

	property int upcomingEventRange: 90 // minutes

	onFetchingData: {
		logger.debug('upcomingEvents.onFetchingData')

	}
	onAllDataFetched: {
		logger.debug('upcomingEvents.onAllDataFetched',
			upcomingEvents.dateMin.toISOString(),
			timeModel.currentTime.toISOString(),
			upcomingEvents.dateMax.toISOString()
		)
		// sendEventListNotification()
	}

	function isUpcomingEvent(eventItem) {
		// console.log(eventItem.startDateTime, timeModel.currentTime, eventItem.startDateTime - timeModel.currentTime, eventItem.summary)
		var dt = eventItem.startDateTime - timeModel.currentTime
		return -30 * 1000 <= dt && dt <= upcomingEventRange * 60 * 1000 // starting within 90 minutes
	}

	function isSameMinute(a, b) {
		return a.getFullYear() == b.getFullYear()
			&& a.getMonth() == b.getMonth()
			&& a.getDate() == b.getDate()
			&& a.getHours() == b.getHours()
			&& a.getMinutes() == b.getMinutes()
	}

	function isEventStarting(eventItem) {
		return isSameMinute(timeModel.currentTime, eventItem.startDateTime) // starting this minute
	}

	function isEventInProgress(eventItem) {
		return eventItem.startDateTime <= timeModel.currentTime && timeModel.currentTime < eventItem.endDateTime
	}

	function filterEvents(predicate) {
		var events = []
		for (var calendarId in eventsByCalendar) {
			var calendar = eventsByCalendar[calendarId]
			calendar.items.forEach(function(eventItem, index, calendarEventList) {
				if (predicate(eventItem)) {
					events.push(eventItem)
				}
			})
		}
		return events
	}

	function formatHeading(heading) {
		var line = ''
		line += '<font size="4"><u>'
		line += heading
		line += '</u></font>'
		return line
	}

	function formatEvent(eventItem) {
		var line = ''
		line += '<font color="' + eventItem.backgroundColor + '">■</font> '
		line += '<b>' + eventItem.summary + ':</b> '
		line += LocaleFuncs.formatEventDuration(eventItem, {
			relativeDate: timeModel.currentTime,
			clock24h: appletConfig.clock24h,
		})
		return line
	}

	function formatEventList(events, heading) {
		var lines = []
		if (events.length > 0 && heading) {
			lines.push(formatHeading(heading))
		}
		events.forEach(function(eventItem) {
			lines.push(formatEvent(eventItem))
		})
		return lines
	}

	function addEventList(lines, heading, events) {
		var newLines = formatEventList(events, heading)
		lines.push.apply(lines, newLines)
	}

	function sendEventListNotification(args) {
		args = args || {}
		var eventsStarting = []
		var eventsInProgress = []
		var upcomingEvents = []
		for (var calendarId in eventsByCalendar) {
			var calendar = eventsByCalendar[calendarId]
			calendar.items.forEach(function(eventItem, index, calendarEventList) {
				if (isEventStarting(eventItem)) {
					eventsStarting.push(eventItem)
				} else if (isEventInProgress(eventItem)) {
					eventsInProgress.push(eventItem)
				} else if (isUpcomingEvent(eventItem)) {
					upcomingEvents.push(eventItem)
				}
			})
		}

		var lines = []
		if (typeof args.showEventsStarting !== "undefined" ? args.showEventsStarting : true) {
			addEventList(lines, i18n("Events Starting"), eventsStarting)
		}
		if (typeof args.showEventInProgress !== "undefined" ? args.showEventInProgress : true) {
			addEventList(lines, i18n("Events In Progress"), eventsInProgress)
		}
		if (typeof args.showUpcomingEvent !== "undefined" ? args.showUpcomingEvent : true) {
			addEventList(lines, i18n("Upcoming Events"), upcomingEvents)
		}

		if (lines.length >= 0) {
			var summary = i18n("Calendar")
			// var summary = lines.splice(0, 1)[0] // pop first item of array
			var bodyText = lines.join('<br />')
			bodyText = bodyText

			notificationManager.notify({
				appName: i18n("Event Calendar"),
				appIcon: "view-calendar-upcoming-events",
				summary: summary,
				body: bodyText,
			})
		}
	}

	function sendEventsStartingNotification() {
		sendEventListNotification({
			showEventInProgress: false,
			showUpcomingEvent: false,
		})
	}

	function sendEventStartingNotification(eventItem) {
		notificationManager.notify({
			appName: i18n("Event Calendar"),
			appIcon: "view-calendar-upcoming-events",
			// expireTimeout: 10000,
			summary: eventItem.summary,
			body: LocaleFuncs.formatEventDuration(eventItem, {
				relativeDate: timeModel.currentTime,
				clock24h: appletConfig.clock24h,
			}),
			soundFile: plasmoid.configuration.eventStartingSfxEnabled ? plasmoid.configuration.eventStartingSfxPath : '',
		})
	}

	function checkForEventsStarting() {
		for (var calendarId in eventsByCalendar) {
			var calendar = eventsByCalendar[calendarId]
			calendar.items.forEach(function(eventItem, index, calendarEventList) {
				if (isEventStarting(eventItem)) {
					if (plasmoid.configuration.eventStartingNotificationEnabled) {
						sendEventStartingNotification(eventItem)
					}
				}
			})
		}
	}

	function tick() {
		checkForEventsStarting()
	}

	Connections {
		target: eventModel
		onAllDataFetched: {
			logger.debug('upcomingEvents eventModel.onAllDataFetched', eventModel.dateMin, timeModel.currentTime, eventModel.dateMax)
			// if data is from current month
			if (eventModel.dateMin <= timeModel.currentTime && timeModel.currentTime <= eventModel.dateMax) {
				logger.debug('syncing upcomingEvents with eventModel')
				upcomingEvents.clear()
				upcomingEvents.dateMin = eventModel.dateMin
				upcomingEvents.dateMax = eventModel.dateMax
				upcomingEvents.eventsByCalendar = eventModel.eventsByCalendar
				upcomingEvents.allDataFetched()
			}
		}
	}

	Connections {
		target: timeModel
		onMinuteChanged: upcomingEvents.tick()
	}
}
