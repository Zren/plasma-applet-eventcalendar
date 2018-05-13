import QtQuick 2.0
import QtQuick.Layouts 1.1

import "Shared.js" as Shared

ListModel {
	id: agendaModel
	property var eventModel
	property var weatherModel
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

	function buildAgendaItem(dateTime) {
		return {
			date: new Date(dateTime),
			events: [],
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
		var index = -1;
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i];
			if (Shared.isSameDate(day, agendaItem.date)) {
				index = i;
				break;
			}
		}
		if (index >= 0) {
			// It does, so skip.
			return;
		}

		// It doesn't, so we need to insert an item.
		var newAgendaItem = buildAgendaItem(day);

		// Insert before the agendaItem with a higher date.
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i];
			if (Shared.isDateEarlier(day, agendaItem.date)) {
				index = i;
				break;
			}
		}

		if (index >= 0) {
			// Insert at index
			agendaItemList.splice(i, 0, newAgendaItem);
		} else {
			// Append
			agendaItemList.push(newAgendaItem);
		}
		// console.log('uneventfulDay:', day);
	}

	function getAgendaItemByDate(agendaItemList, date) {
		for (var i = 0; i < agendaItemList.length; i++) {
			var agendaItem = agendaItemList[i];
			if (Shared.isSameDate(agendaItem.date, date)) {
				return agendaItem;
			}
		}
		return null;
	}
	function insertEventAtDate(agendaItemList, date, eventItem) {
		var agendaItem = getAgendaItemByDate(agendaItemList, date);
		if (!agendaItem) {
			agendaItem = buildAgendaItem(date);
			agendaItemList.push(agendaItem);
		}
		agendaItem.events.push(eventItem);
	}
	function parseGCalEvents(data) {
		agendaModel.populating = true
		// agendaModel.clear();

		if (!(data && data.items)) {
			agendaModel.populating = false
			return;
		}

		data.items.sort(function(a,b) { return a.start.dateTime - b.start.dateTime; });

		var agendaItemList = [];

		for (var i = 0; i < data.items.length; i++) {
			var eventItem = data.items[i];
			if (plasmoid.configuration.agenda_breakup_multiday_events) {
				// for Max(start, visibleMin) .. Min(end, visibleMax)
				var lowerLimitDate = agendaModel.clipEventsOutsideLimits && eventItem.start.dateTime < agendaModel.visibleDateMin ? agendaModel.visibleDateMin : eventItem.start.dateTime;
				var upperLimitDate = eventItem.end.dateTime;
				if (eventItem.end.date) {
					// All Day event "ends" day before.
					upperLimitDate = new Date(eventItem.end.dateTime);
					upperLimitDate.setDate(upperLimitDate.getDate() - 1);
				}
				if (agendaModel.clipEventsOutsideLimits && upperLimitDate > agendaModel.visibleDateMax) {
					upperLimitDate = agendaModel.visibleDateMax;
				}
				for (var eventItemDate = new Date(lowerLimitDate); eventItemDate <= upperLimitDate; eventItemDate.setDate(eventItemDate.getDate() + 1)) {
					insertEventAtDate(agendaItemList, eventItemDate, eventItem);
				}
			} else {
				var now = new Date(timeModel.currentTime);
				var inProgress = eventItem.start.dateTime <= now && now <= eventItem.end.dateTime;
				if (inProgress) {
					insertEventAtDate(agendaItemList, now, eventItem);
				} else {
					insertEventAtDate(agendaItemList, eventItem.start.dateTime, eventItem);
				}
			}
		}

		var today = new Date(timeModel.currentTime);
		var nextNumDaysEnd = new Date(today.getFullYear(), today.getMonth(), today.getDate() + showNextNumDays);
		var currentMonthMin = new Date(currentMonth.getFullYear(), currentMonth.getMonth(), 1);
		var currentMonthMaxExclusive = new Date(currentMonth.getFullYear(), currentMonth.getMonth()+1, 1);

		if (clipEventsFromOtherMonths) {
			// Remove calendar from different months
			for (var i = 0; i < agendaItemList.length; i++) {
				var agendaItem = agendaItemList[i];
				if (agendaItem.date < currentMonthMin || currentMonthMaxExclusive <= agendaItem.date && nextNumDaysEnd <= agendaItem.date) {
					// console.log('removed agendaItem:', agendaItem.date)
					agendaItemList.splice(i, 1);
					i--;
				}
			}
		}

		if (showAllDaysInMonth) {
			for (var day = new Date(currentMonthMin); day < currentMonthMaxExclusive; day.setDate(day.getDate() + 1)) {
				addAgendaItemIfMissing(agendaItemList, day)
			}
		}

		if (showNextNumDays > 0) {
			var todayMidnight = new Date(today.getFullYear(), today.getMonth(), today.getDate());
			for (var day = todayMidnight; day <= nextNumDaysEnd; day.setDate(day.getDate() + 1)) {
				addAgendaItemIfMissing(agendaItemList, day)
			}
		}
		
		if (clipPastEvents) {
			// Remove calendar events before today.
			var minDate = today;
			if (!clipPastEventsToday) {
				minDate = new Date(today.getFullYear(), today.getMonth(), today.getDate());
			}
			for (var i = 0; i < agendaItemList.length; i++) {
				var agendaItem = agendaItemList[i];
				if (agendaItem.date < minDate) {
					// console.log('removed agendaItem:', agendaItem.date)
					agendaItemList.splice(i, 1);
					i--;
				}
			}
		}

		// Make sure the agendaItemList is sorted.
		// When we have a in-progress multiday event on the current date,
		// and cfg_agenda_breakup_multiday_events is false, the current date agendaItem is
		// out of order since the agendaItem is inserted earlier.
		agendaItemList.sort(function(a,b) { return a.date - b.date; });


		var minCount = Math.min(agendaItemList.length, agendaModel.count)
		var maxCount = Math.max(agendaItemList.length, agendaModel.count)
		// console.log('agendaModel', 'replaced items', minCount)
		for (var i = 0; i < minCount; i++) {
			agendaModel.set(i, agendaItemList[i]); // Replace the existing values
		}
		if (agendaItemList.length > agendaModel.count) {
			// console.log('agendaModel', 'append items', minCount, maxCount, maxCount-minCount)
			for (var i = minCount; i < agendaItemList.length; i++) {
				agendaModel.append(agendaItemList[i]); // Add the missing delegates
			}
		} else if (agendaItemList.length < agendaModel.count) {
			// console.log('agendaModel', 'removed items', minCount, maxCount, maxCount-minCount)
			agendaModel.remove(minCount, maxCount-minCount); // Remove the extra delegates
			// for (var i = 0; i < agendaItemList.length; i++) {
			// 	agendaModel.remove(i, agendaItemList[i]); // Remove the extra delegates
			// }
		} else { // agendaItemList.length == agendaModel.count
			// console.log('agendaModel', 'skip')
			// skip
		}
		agendaModel.populating = false
	}

	function parseWeatherForecast(data) {
		if (!(data && data.list))
			return;

		var showWeatherColumn = false
		for (var j = 0; j < data.list.length; j++) {
			var forecastItem = data.list[j];
			var day = new Date(forecastItem.dt * 1000);

			for (var i = 0; i < agendaModel.count; i++) {
				var agendaItem = agendaModel.get(i);
				if (Shared.isSameDate(day, agendaItem.date)) {
					// logger.debug('parseWeatherForecast', day);
					agendaItem.tempLow = Math.floor(forecastItem.temp.min);
					agendaItem.tempHigh = Math.ceil(forecastItem.temp.max);
					agendaModel.setProperty(i, 'tempLow', Math.floor(forecastItem.temp.min));
					agendaModel.setProperty(i, 'tempHigh', Math.ceil(forecastItem.temp.max));
					agendaModel.setProperty(i, 'weatherIcon', forecastItem.iconName || 'weather-severe-alert');
					agendaModel.setProperty(i, 'weatherText', forecastItem.text || '');
					agendaModel.setProperty(i, 'weatherDescription', forecastItem.description || '');
					agendaModel.setProperty(i, 'weatherNotes', forecastItem.notes || '');
					agendaModel.setProperty(i, 'showWeather', true);
					showWeatherColumn = true
					break;
				}
			}
		}
		agendaModel.showDailyWeather = showWeatherColumn
	}

	Component.onCompleted: {
		parseGCalEvents({ "items": [], });
		parseWeatherForecast({ "list": [], });
	}
}
