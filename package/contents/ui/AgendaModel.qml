import QtQuick 2.0

import "Shared.js" as Shared

ListModel {
	id: agendaModel
	property var eventModel
	property var timeModel

	dynamicRoles: false

	property bool populating: false
	// onPopulatingChanged: console.log(Date.now(), 'agendaModel.populating', populating)

	property bool showDailyWeather: false

	property int showNextNumDays: 14
	property bool showAllDaysInMonth: true
	property bool clipPastEvents: false
	property bool clipPastEventsToday: false
	property bool clipEventsOutsideLimits: true
	property bool clipEventsFromOtherMonths: true
	property date visibleDateMin: new Date()
	property date visibleDateMax: new Date()
	property date currentMonth: new Date()

	function getDateRange(targetDate) {
		// console.log('getDateRange')
		// console.log('  target', targetDate)
		var today = new Date(timeModel.currentTime)
		// console.log('   today', today)

		// We could calculate how many days are shown before the start of the month,
		// like monthView.firstDisplayedDate() does, but it's easier to just fetch
		// a constant 7 days and crop the unused events.
		var targetMonthMin = new Date(targetDate.getFullYear(), targetDate.getMonth(), 1)
		var dateMin = new Date(targetMonthMin.getFullYear(), targetMonthMin.getMonth(), targetMonthMin.getDate() - 7)

		// Same as dateMin, we just add 7 days after the end of the month,
		// instead of using monthView.lastDisplayedDate(), as it's easier.
		// targetMonthMaxExclusive is the first day of the next month,
		// so we only need to add 6 days.
		var targetMonthMaxExclusive = new Date(targetDate.getFullYear(), targetDate.getMonth()+1, 1)
		var monthViewDateMax = new Date(targetMonthMaxExclusive.getFullYear(), targetMonthMaxExclusive.getMonth(), targetMonthMaxExclusive.getDate() + 6)

		// If the targetDate is from today's month, then we need to check if
		// agendaViewDateMax is later than monthViewDateMax.
		var targetMonthContainsToday = targetMonthMin <= today && today < targetMonthMaxExclusive
		var dateMax
		if (targetMonthContainsToday) {
			var agendaViewDateMax = new Date(today.getFullYear(), today.getMonth(), today.getDate() + agendaModel.showNextNumDays)
			dateMax = new Date(Math.max(monthViewDateMax, agendaViewDateMax))
		} else {
			dateMax = monthViewDateMax
		}

		// console.log('     min', dateMin)
		// console.log('     max', dateMax)
		return {
			min: dateMin,
			max: dateMax,
		}
	}

	function buildAgendaItem(dateTime) {
		return {
			date: new Date(dateTime),
			events: [],
			tasks: [],
			showWeather: false,
			tempLow: 0,
			tempHigh: 0,
			weatherIcon: "",
			weatherText: "",
			weatherDescription: "",
			weatherNotes: "",
		};
	}

	function addAgendaItemIfMissing(agendaItemList, day) {
		// console.log(day);

		// Check if an agendaItem with this date already exists.
		var index = -1
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i]
			if (Shared.isSameDate(day, agendaItem.date)) {
				index = i
				break
			}
		}
		if (index >= 0) {
			// It does, so skip.
			return
		}

		// It doesn't, so we need to insert an item.
		var newAgendaItem = buildAgendaItem(day)

		// Insert before the agendaItem with a higher date.
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i]
			if (Shared.isDateEarlier(day, agendaItem.date)) {
				index = i
				break
			}
		}

		if (index >= 0) {
			// Insert at index
			agendaItemList.splice(i, 0, newAgendaItem)
		} else {
			// Append
			agendaItemList.push(newAgendaItem)
		}
		// console.log('uneventfulDay:', day)
	}

	function getAgendaItemByDate(agendaItemList, date) {
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i]
			if (Shared.isSameDate(agendaItem.date, date)) {
				return agendaItem
			}
		}
		return null
	}
	function insertEventAtDate(agendaItemList, date, eventItem) {
		var agendaItem = getAgendaItemByDate(agendaItemList, date);
		if (!agendaItem) {
			agendaItem = buildAgendaItem(date)
			agendaItemList.push(agendaItem)
		}
		if (eventItem.kind == 'tasks#task') {
			agendaItem.tasks.push(eventItem)
		} else {
			agendaItem.events.push(eventItem)
		}
	}

	function sortSubTasks(eventList) {
		// Place subtasks below their parent task
		for (var i = 0; i < eventList.length; i++) {
			var eventItem = eventList[i]
			// console.log('i', i, eventItem.summary)
			if (eventItem.kind == 'tasks#task' && typeof eventItem.parent !== 'undefined') {
				for (var j = 0; j < eventList.length; j++) {
					var parentItem = eventList[j]
					// console.log('  j', j, parentItem.summary)
					if (parentItem.kind == 'tasks#task' && parentItem.id == eventItem.parent) {
						var foundDestination = false
						for (var k = j+1; k < eventList.length; k++) {
							var childItem = eventList[k]
							// console.log('    k', k, childItem.summary)
							if (childItem.kind != 'tasks#task'
								|| childItem.parent != parentItem.id
								|| childItem.position > eventItem.position
							) {
								// Move eventItem from index i => k
								// console.log('      move', eventItem.summary, 'from', i, 'to', k)
								foundDestination = true
								if (i < k) {
									// Since we removed an item before k, decrement the index
									k--
								}
								if (i != k) {
									eventList.splice(i, 1) // Remove at index=i
									eventList.splice(k, 0, eventItem) // Add at index=k
									i-- // Since eventItem was moved, we need to check index=i again.
								}
								break
							}
						} // end loop k

						if (!foundDestination) {
							// Move eventItem from index i => end of list
							var k = eventList.length - 1
							// console.log('      move', eventItem.summary, 'from', i, 'to', k, '(end of list)')
							if (i != k) {
								eventList.splice(i, 1) // Remove at index=i
								eventList.push(eventItem)
								i-- // Since eventItem was moved, we need to check index=i again.
							}
						}

						break
					}
				} // end loop j
			}
		} // end loop i
	}

	function parseGCalEvents(data) {
		agendaModel.populating = true
		// agendaModel.clear()

		if (!(data && data.items)) {
			agendaModel.populating = false
			return
		}

		if (plasmoid.configuration.agendaPlaceOverdueTasksOnToday) {
			for (var i = 0; i < data.items.length; i++) {
				var eventItem = data.items[i]
				if (eventItem.kind == 'tasks#task'
					&& eventItem.due
					&& !eventItem.isCompleted
				) {
					var now = new Date(timeModel.currentTime)
					var taskIsOverdue = eventItem.dueEndTime < now
					if (taskIsOverdue) {
						eventItem.start = {
							date: Shared.dateString(now),
						}
						eventItem.end = {
							date: Shared.dateString(now),
						}
						eventItem.startDateTime = now
						eventItem.endDateTime = now
					}
				}
			}
		}

		// Sort by start time if event, or position if tasks
		data.items.sort(function(a,b) {
			var aIsTask = a.kind == 'tasks#task'
			var bIsTask = b.kind == 'tasks#task'
			if (!aIsTask && bIsTask) {
				return -1
			} else if (aIsTask && !bIsTask) {
				return 1
			} else if (aIsTask && bIsTask) {
				var ap = a.position
				var bp = b.position
				if (ap == bp) {
					return 0
				} else if (ap < bp) {
					return -1
				} else { // ap > bp
					return 1
				}
			} else { // neither is task
				return a.startDateTime - b.startDateTime
			}
		})
		sortSubTasks(data.items)


		var agendaItemList = []

		for (var i = 0; i < data.items.length; i++) {
			var eventItem = data.items[i]
			if (plasmoid.configuration.agendaBreakupMultiDayEvents) {
				// for Max(start, visibleMin) .. Min(end, visibleMax)
				var lowerLimitDate = (agendaModel.clipEventsOutsideLimits && eventItem.startDateTime < agendaModel.visibleDateMin
					? agendaModel.visibleDateMin
					: eventItem.startDateTime
				)
				var upperLimitDate = eventItem.endDateTime
				if (eventItem.end.date) {
					// All Day event "ends" day before.
					upperLimitDate = new Date(eventItem.endDateTime)
					upperLimitDate.setDate(upperLimitDate.getDate() - 1)
				}
				if (agendaModel.clipEventsOutsideLimits && upperLimitDate > agendaModel.visibleDateMax) {
					upperLimitDate = agendaModel.visibleDateMax
				}
				for (var eventItemDate = new Date(lowerLimitDate); eventItemDate <= upperLimitDate; eventItemDate.setDate(eventItemDate.getDate() + 1)) {
					insertEventAtDate(agendaItemList, eventItemDate, eventItem)
				}
			} else {
				var now = new Date(timeModel.currentTime)
				var inProgress = eventItem.startDateTime <= now && now <= eventItem.endDateTime
				if (inProgress) {
					var today = new Date(now.getFullYear(), now.getMonth(), now.getDate())
					insertEventAtDate(agendaItemList, today, eventItem)
				} else {
					insertEventAtDate(agendaItemList, eventItem.startDateTime, eventItem)
				}
			}
		}

		var today = new Date(timeModel.currentTime)
		var nextNumDaysEndExclusive = new Date(today.getFullYear(), today.getMonth(), today.getDate() + showNextNumDays + 1)
		var currentMonthMin = new Date(currentMonth.getFullYear(), currentMonth.getMonth(), 1)
		var currentMonthMaxExclusive = new Date(currentMonth.getFullYear(), currentMonth.getMonth()+1, 1)
		var currentMonthContainsToday = currentMonthMin <= today && today < currentMonthMaxExclusive

		if (clipEventsFromOtherMonths) {
			// Remove calendar from different months
			for (var i = 0; i < agendaItemList.length; i++) {
				var agendaItem = agendaItemList[i]
				if (agendaItem.date < currentMonthMin || currentMonthMaxExclusive <= agendaItem.date && nextNumDaysEndExclusive < agendaItem.date) {
					// console.log('removed agendaItem:', agendaItem.date)
					agendaItemList.splice(i, 1)
					i--
				}
			}
		}

		if (showAllDaysInMonth) {
			for (var day = new Date(currentMonthMin); day < currentMonthMaxExclusive; day.setDate(day.getDate() + 1)) {
				addAgendaItemIfMissing(agendaItemList, day)
			}
		}

		if (currentMonthContainsToday && showNextNumDays > 0) {
			var todayMidnight = new Date(today.getFullYear(), today.getMonth(), today.getDate())
			for (var day = todayMidnight; day < nextNumDaysEndExclusive; day.setDate(day.getDate() + 1)) {
				addAgendaItemIfMissing(agendaItemList, day)
			}
		}
		
		if (clipPastEvents) {
			// Remove calendar events before today.
			var minDate = today
			if (!clipPastEventsToday) {
				minDate = new Date(today.getFullYear(), today.getMonth(), today.getDate())
			}
			for (var i = 0; i < agendaItemList.length; i++) {
				var agendaItem = agendaItemList[i]
				if (agendaItem.date < minDate) {
					// console.log('removed agendaItem:', agendaItem.date)
					agendaItemList.splice(i, 1)
					i--
				}
			}
		}

		// Make sure the agendaItemList is sorted.
		// When we have a in-progress multiday event on the current date,
		// and agendaBreakupMultiDayEvents is false, the current date agendaItem is
		// out of order since the agendaItem is inserted earlier.
		agendaItemList.sort(function(a,b) { return a.date - b.date })


		var minCount = Math.min(agendaItemList.length, agendaModel.count)
		var maxCount = Math.max(agendaItemList.length, agendaModel.count)
		// console.log('agendaModel', 'replaced items', minCount)
		for (var i = 0; i < minCount; i++) {
			agendaModel.set(i, agendaItemList[i]) // Replace the existing values
		}
		if (agendaItemList.length > agendaModel.count) {
			// console.log('agendaModel', 'append items', minCount, maxCount, maxCount-minCount)
			for (var i = minCount; i < agendaItemList.length; i++) {
				agendaModel.append(agendaItemList[i]) // Add the missing delegates
			}
		} else if (agendaItemList.length < agendaModel.count) {
			// console.log('agendaModel', 'removed items', minCount, maxCount, maxCount-minCount)
			agendaModel.remove(minCount, maxCount-minCount) // Remove the extra delegates
			// for (var i = 0; i < agendaItemList.length; i++) {
			// 	agendaModel.remove(i, agendaItemList[i]) // Remove the extra delegates
			// }
		} else { // agendaItemList.length == agendaModel.count
			// console.log('agendaModel', 'skip')
			// skip
		}
		agendaModel.populating = false
	}

	function parseWeatherForecast(data) {
		if (!(data && data.list)) {
			return
		}

		var showWeatherColumn = false
		for (var j = 0; j < data.list.length; j++) {
			var forecastItem = data.list[j]
			var day = new Date(forecastItem.dt * 1000)

			for (var i = 0; i < agendaModel.count; i++) {
				var agendaItem = agendaModel.get(i)
				if (Shared.isSameDate(day, agendaItem.date)) {
					// logger.debug('parseWeatherForecast', day)
					agendaItem.tempLow = Math.floor(forecastItem.temp.min)
					agendaItem.tempHigh = Math.ceil(forecastItem.temp.max)
					agendaModel.setProperty(i, 'tempLow', Math.floor(forecastItem.temp.min))
					agendaModel.setProperty(i, 'tempHigh', Math.ceil(forecastItem.temp.max))
					agendaModel.setProperty(i, 'weatherIcon', forecastItem.iconName || 'weather-severe-alert')
					agendaModel.setProperty(i, 'weatherText', forecastItem.text || '')
					agendaModel.setProperty(i, 'weatherDescription', forecastItem.description || '')
					agendaModel.setProperty(i, 'weatherNotes', forecastItem.notes || '')
					agendaModel.setProperty(i, 'showWeather', true)
					showWeatherColumn = true
					break
				}
			}
		}
		agendaModel.showDailyWeather = showWeatherColumn
	}

	Component.onCompleted: {
		parseGCalEvents({ "items": [] })
		parseWeatherForecast({ "list": [] })
	}
}
