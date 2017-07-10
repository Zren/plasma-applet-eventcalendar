import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi
import "../code/DebugFixtures.js" as DebugFixtures

Item {
    id: agendaView

    //anchors.margins: units.largeSpacing
    property int spacing: units.largeSpacing
    property alias agendaListView: agendaListView

    property int showNextNumDays: 14
    property bool showAllDaysInMonth: true
    property bool clipPastEvents: false
    property bool clipPastEventsToday: false
    property bool clipEventsOutsideLimits: true
    property bool clipEventsFromOtherMonths: true
    property date visibleDateMin: new Date()
    property date visibleDateMax: new Date()
    property date currentMonth: new Date()
    property date currentTime: timeModel.currentTime

    property color inProgressColor: appletConfig.agendaInProgressColor
    property int inProgressFontWeight: Font.Bold

    signal newEventFormOpened(variant agendaItem, variant newEventCalendarId)
    signal submitNewEventForm(variant calendarId, variant date, string text)

    property alias agendaModel: agendaListView.model

    // width: 400
    // height: 400

    // Testing with qmlview
    Rectangle {
        visible: typeof popup === 'undefined'
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }
    
    ListView {
        id: agendaListView
        // model: ListModel {}
        model: root.agendaModel
        anchors.fill: parent
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds

        // Don't bother garbage collecting
        // GC or Reloading the weather images is very slow.
        cacheBuffer: 10000000 

        delegate: AgendaListItem {}
    }

    function scrollToTop() {
        agendaListView.positionViewAtBeginning()
    }

    function scrollToDate(date) {
        for (var i = 0; i < agendaModel.count; i++) {
            var agendaItem = agendaModel.get(i);
            if (Shared.isSameDate(date, agendaItem.date)) {
                agendaListView.positionViewAtIndex(i, ListView.Beginning);
                return;
            } else if (Shared.isDateEarlier(date, agendaItem.date)) {
                // If the date is smaller than the current agendaItem.date, scroll to the previous agendaItem.
                if (i > 0) {
                    agendaListView.positionViewAtIndex(i-1, ListView.Beginning);
                } else {
                    agendaListView.positionViewAtBeginning()
                }
                return;
            }
        }
        // If the date is greater than any item in the agenda, scroll to the bottom.
        agendaListView.positionViewAtEnd()
    }

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

    function parseGCalEvents(data) {
        agendaModel.clear();
        // currentTime = new Date();

        if (!(data && data.items))
            return;

        // var eventItemList = [];
        // var timeZoneOffset = new Date().getTimezoneOffset()/60;
        // timeZoneOffset = 'Z' + (timeZoneOffset > 0 ? '-' : '+') + timeZoneOffset + '00';
        // console.log(timeZoneOffset);
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];

            if (eventItem.start.date) {
                eventItem.start.dateTime = new Date(eventItem.start.date + ' 00:00:00');
            } else {
                eventItem.start.dateTime = new Date(eventItem.start.dateTime);
            }
            // console.log(eventItem.start.dateTime, eventItem.summary);

            if (eventItem.end.date) {
                eventItem.end.dateTime = new Date(eventItem.end.date + ' 00:00:00');
            } else {
                eventItem.end.dateTime = new Date(eventItem.end.dateTime);
            }

            // eventItemList.push(eventItem);
        }
        data.items.sort(function(a,b) { return a.start.dateTime - b.start.dateTime; });

        // for (var i = 0; i < data.items.length; i++) {
        //     var eventItem = data.items[i];
        //     console.log(eventItem.start.dateTime, eventItem.summary);
        // }

        var agendaItemList = [];
        function getAgendaItemByDate(date) {
            for (var i = 0; i < agendaItemList.length; i++) {
                var agendaItem = agendaItemList[i];
                if (Shared.isSameDate(agendaItem.date, date)) {
                    return agendaItem;
                }
            }
            return null;
        }
        function insertEventAtDate(date, eventItem) {
            var agendaItem = getAgendaItemByDate(date);
            if (!agendaItem) {
                agendaItem = buildAgendaItem(date);
                agendaItemList.push(agendaItem);
            }
            agendaItem.events.push(eventItem);
        }
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];
            if (plasmoid.configuration.agenda_breakup_multiday_events) {
                // for Max(start, visibleMin) .. Min(end, visibleMax)
                var lowerLimitDate = agendaView.clipEventsOutsideLimits && eventItem.start.dateTime < agendaView.visibleDateMin ? agendaView.visibleDateMin : eventItem.start.dateTime;
                var upperLimitDate = eventItem.end.dateTime;
                if (eventItem.end.date) {
                    // All Day event "ends" day before.
                    upperLimitDate = new Date(eventItem.end.dateTime);
                    upperLimitDate.setDate(upperLimitDate.getDate() - 1);
                }
                if (agendaView.clipEventsOutsideLimits && upperLimitDate > agendaView.visibleDateMax) {
                    upperLimitDate = agendaView.visibleDateMax;
                }
                for (var eventItemDate = new Date(lowerLimitDate); eventItemDate <= upperLimitDate; eventItemDate.setDate(eventItemDate.getDate() + 1)) {
                    insertEventAtDate(eventItemDate, eventItem);
                }
            } else {
                var now = new Date(agendaView.currentTime);
                var inProgress = eventItem.start.dateTime <= now && now <= eventItem.end.dateTime;
                if (inProgress) {
                    insertEventAtDate(now, eventItem);
                } else {
                    insertEventAtDate(eventItem.start.dateTime, eventItem);
                }
            }
        }

        var today = new Date(agendaView.currentTime);
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

        for (var i = 0; i < agendaItemList.length; i++) {
            agendaModel.append(agendaItemList[i]);
        }
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

        if (typeof root === 'undefined') {
            logger.log('[AgendaView] now = new Date()')
            var now = new Date()
            visibleDateMin = new Date(now.getFullYear(), now.getMonth(), 1)
            visibleDateMax = new Date(now.getFullYear(), now.getMonth()+1, 0)
            clipPastEvents = false
            parseGCalEvents(DebugFixtures.getEventData());
            parseWeatherForecast(DebugFixtures.getDailyWeatherData());
        }
    }
}
