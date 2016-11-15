import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi
import "../code/DebugFixtures.js" as DebugFixtures

Item {
    id: popup

    // use Layout.prefferedHeight instead of height so that the plasmoid resizes.
    // width: columnWidth + 10 + columnWidth
    property int spacing: 10 * units.devicePixelRatio
    property int topRowHeight: 100 * units.devicePixelRatio
    property int bottomRowHeight: 400 * units.devicePixelRatio
    property int columnWidth: width / 2
    property int padding: 0

    Layout.minimumWidth: {
        if (showAgenda && showCalendar) {
            return (400 + 10 + 400) * units.devicePixelRatio
        } else {
            return 400 * units.devicePixelRatio
        }
    }
    Layout.preferredWidth: {
        if (showAgenda && showCalendar) {
            return (400 + 10 + 400) * units.devicePixelRatio + padding * 2
        } else {
            return 400 * units.devicePixelRatio + padding * 2
        }
    }
    Layout.maximumWidth: plasmoid.screenGeometry.width

    Layout.minimumHeight: 400 * units.devicePixelRatio
    Layout.preferredHeight: {
        if ((showMeteogram || showTimer) && (showAgenda || showCalendar)) {
            return (400 + 10 + 100) * units.devicePixelRatio + padding * 2
        } else {
            return 400 * units.devicePixelRatio + padding * 2
        }
    }
    Layout.maximumHeight: plasmoid.screenGeometry.height

    property var eventModel
    property var weatherModel
    // property alias agendaModel: agendaView.agendaModel

    // Overload with config: plasmoid.configuration
    property variant config: { }
    property bool showMeteogram: plasmoid.configuration.widget_show_meteogram
    property bool showTimer: plasmoid.configuration.widget_show_timer
    property bool showAgenda: plasmoid.configuration.widget_show_agenda
    property bool showCalendar: plasmoid.configuration.widget_show_calendar
    property bool agendaScrollOnSelect: true
    property bool cfg_agenda_scroll_on_monthchange: false
    
    property alias agendaListView: agendaView.agendaListView
    property alias today: monthView.today
    property alias selectedDate: monthView.currentDate
    property alias monthViewDate: monthView.displayedDate
    property date visibleDateMin: new Date()
    property date visibleDateMax: new Date()
    property variant dailyWeatherData: { "list": [] }
    property variant hourlyWeatherData: { "list": [] }
    property variant currentWeatherData: null
    property variant lastForecastAt: null

    Connections {
        target: monthView
        onDateSelected: {
            // console.log('onDateSelected', selectedDate)
            scrollToSelection()
        }   
    }
    function scrollToSelection() {
        if (!agendaScrollOnSelect)
            return;
        if (true) {
            agendaView.scrollToDate(selectedDate)
        } else {
            agendaView.scrollToTop()
        }
    }

    Connections {
        target: plasmoid.configuration
        onWeather_serviceChanged: {
            popup.dailyWeatherData = { "list": [] }
            popup.hourlyWeatherData = { "list": [] }
            popup.currentWeatherData = null
            popup.updateUI()
        }
    }

    onMonthViewDateChanged: {
        // console.log('onMonthViewDateChanged', monthViewDate)
        var startOfMonth = new Date(monthViewDate);
        startOfMonth.setDate(1);
        agendaView.currentMonth = new Date(startOfMonth);
        if (cfg_agenda_scroll_on_monthchange) {
            selectedDate = startOfMonth;
        }
        updateEvents();
    }

    onStateChanged: {
        // console.log(popup.state, widgetGrid.columns, widgetGrid.rows)
    }
    states: [
        State {
            name: "agenda+month"
            when: popup.showAgenda && popup.showCalendar && !popup.showMeteogram && !popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 1
            }
        },
        State {
            name: "meteogram+agenda+month"
            when: popup.showAgenda && popup.showCalendar && popup.showMeteogram && !popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
            PropertyChanges { target: meteogramView
                Layout.columnSpan: 2
            }
        },
        State {
            name: "timer+agenda+month"
            when: popup.showAgenda && popup.showCalendar && !popup.showMeteogram && popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
            PropertyChanges { target: timerView
                Layout.columnSpan: 2
            }
        },
        State {
            name: "meteogram+timer+agenda+month"
            when: popup.showAgenda && popup.showCalendar && popup.showMeteogram && popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
        },
        State {
            name: "singleColumn"
            when: !(popup.showAgenda && popup.showCalendar)

            PropertyChanges { target: widgetGrid
                columns: 1
            }
        }
    ]

    ColumnLayout {
        width: parent.width
        height: parent.height

        GridLayout {
            id: widgetGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columnSpacing: popup.spacing
            rowSpacing: popup.spacing
            onColumnsChanged: {
                // console.log(popup.state, widgetGrid.columns, widgetGrid.rows)
            }
            onRowsChanged: {
                // console.log(popup.state, widgetGrid.columns, widgetGrid.rows)
            }
            Layout.margins: popup.padding


            ForecastGraph {
                id: meteogramView
                visible: showMeteogram
                Layout.fillWidth: true
                Layout.minimumHeight: popup.topRowHeight
                Layout.preferredHeight: parent.height / 5
                cfg_meteogram_hours: plasmoid.configuration.meteogram_hours
                showIconOutline: plasmoid.configuration.show_outlines
                xAxisScale: 1 / hoursPerDataPoint
                xAxisLabelEvery: Math.ceil(3 / hoursPerDataPoint)
                property int hoursPerDataPoint: WeatherApi.getDataPointDuration()

                Rectangle {
                    anchors.fill: parent
                    anchors.margins: 10
                    color: "transparent"
                    border.color: theme.buttonBackgroundColor
                    border.width: 1
                    visible: !WeatherApi.weatherIsSetup()

                    PlasmaComponents.Label {
                        anchors.centerIn: parent
                        text: i18n("Weather not configured.\nGo to Weather in the config and set your city,\nand/or disable the meteogram to hide this area.")
                    }
                }
            }

            TimerView {
                id: timerView
                visible: showTimer
                Layout.fillWidth: true
                Layout.minimumHeight: popup.topRowHeight
                Layout.preferredHeight: parent.height / 5
            }

            AgendaView {
                id: agendaView
                visible: showAgenda

                Layout.preferredWidth: parent.width / 2
                Layout.fillWidth: true
                Layout.fillHeight: true

                visibleDateMin: popup.visibleDateMin
                visibleDateMax: popup.visibleDateMax

                onNewEventFormOpened: {
                    // console.log('onNewEventFormOpened')
                    if (plasmoid.configuration.access_token) {
                        var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
                        var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
                        // console.log('calendarList', JSON.stringify(calendarList, null, '\t'))
                        var list = []
                        var selectedIndex = 0;
                        calendarList.forEach(function(calendar){
                            if (calendar.accessRole == 'owner') {
                                if (plasmoid.configuration.agenda_newevent_remember_calendar && calendar.id === plasmoid.configuration.agenda_newevent_last_calendar_id) {
                                    selectedIndex = list.length; // index after insertion
                                }
                                list.push({
                                    'calendarId': calendar.id,
                                    'text': calendar.summary,
                                })
                            }
                        });
                        newEventCalendarId.model = list
                        newEventCalendarId.currentIndex = selectedIndex
                    }
                }
                onSubmitNewEventForm: {
                    // console.log('onSubmitNewEventForm', calendarId)
                    if (plasmoid.configuration.access_token) {
                        var calendarId2 = calendarId.calendarId ? calendarId.calendarId : calendarId
                        var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
                        var dateString = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate()
                        // console.log('text', dateString + ' ' + text)
                        if (plasmoid.configuration.agenda_newevent_remember_calendar) {
                            plasmoid.configuration.agenda_newevent_last_calendar_id = calendarId2
                        }
                        Shared.createGCalEvent({
                            access_token: plasmoid.configuration.access_token,
                            calendarId: calendarId2,
                            text: dateString + ' ' + text,
                        }, function(err, data) {
                            // console.log(err, JSON.stringify(data, null, '\t'));
                            var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
                            if (calendarIdList.indexOf(calendarId2) >= 0) {
                                eventModel.eventsByCalendar[calendarId2].items.push(data);
                                updateUI()
                            }
                        })
                    }
                }
                PlasmaComponents.Button {
                    iconSource: 'view-refresh'
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    onClicked: {
                        updateEvents()
                        updateWeather(true)
                    }
                }
            }

            MonthView {
                id: monthView
                visible: showCalendar
                borderOpacity: plasmoid.configuration.month_show_border ? 0.25 : 0
                showWeekNumbers: plasmoid.configuration.month_show_weeknumbers

                Layout.preferredWidth: parent.width/2
                Layout.fillWidth: true
                Layout.fillHeight: true

                // Component.onCompleted: {
                //     today = new Date();
                // }

                function parseGCalEvents(data) {
                    if (!(data && data.items))
                        return;

                    // Clear event data since data contains events from all calendars, and this function
                    // is called every time a calendar is recieved.
                    for (var i = 0; i < monthView.daysModel.count; i++) {
                        var dayData = monthView.daysModel.get(i);
                        monthView.daysModel.setProperty(i, 'showEventBadge', false);
                        dayData.events.clear();
                    }

                    // https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/daysmodel.h
                    for (var j = 0; j < data.items.length; j++) {
                        var eventItem = data.items[j];
                        var eventItemStartDate = new Date(eventItem.start.dateTime.getFullYear(), eventItem.start.dateTime.getMonth(), eventItem.start.dateTime.getDate());
                        var eventItemEndDate = new Date(eventItem.end.dateTime.getFullYear(), eventItem.end.dateTime.getMonth(), eventItem.end.dateTime.getDate());
                        if (eventItem.end.date) {
                            // All day events end at midnight which is technically the next day.
                            eventItemEndDate.setDate(eventItemEndDate.getDate() - 1);
                        }
                        // console.log(eventItemStartDate, eventItemEndDate)
                        for (var i = 0; i < monthView.daysModel.count; i++) {
                            var dayData = monthView.daysModel.get(i);
                            var dayDataDate = new Date(dayData.yearNumber, dayData.monthNumber - 1, dayData.dayNumber);
                            if (eventItemStartDate <= dayDataDate && dayDataDate <= eventItemEndDate) {
                                // console.log('\t', dayDataDate)
                                monthView.daysModel.setProperty(i, 'showEventBadge', true);
                                var events = dayData.events || [];
                                events.append(eventItem);
                                monthView.daysModel.setProperty(i, 'events', events);
                            } else if (eventItemEndDate < dayDataDate) {
                                break;
                            }
                        }
                    }
                }

                onDayDoubleClicked: {
                    var date = new Date(dayData.yearNumber, dayData.monthNumber-1, dayData.dayNumber);
                    // console.log('Popup.monthView.onDoubleClicked', date);
                    if (true) {
                        // cfg_month_day_doubleclick == "browser_newevent"
                        Shared.openGoogleCalendarNewEventUrl(date);
                    }
                }
            }

            
        }
    }

    Component.onCompleted: {
        if (typeof root === 'undefined') {
            console.log('today = new Date()')
            today = new Date();
        }
        update();
        if (typeof root === 'undefined') {
            // eventModel.eventsByCalendar['debug'] = DebugFixtures.getEventData();
            eventModel.eventsData = DebugFixtures.getEventData();
            // updateUI();
            // agendaView.parseGCalEvents(eventsData);
            // monthView.parseGCalEvents(eventsData);
        }
        polltimer.start()
    }
        
    Timer {
        id: polltimer
        
        repeat: true
        triggeredOnStart: true
        interval: plasmoid.configuration.events_pollinterval * 60000
        onTriggered: update()
    }

    function update() {
        updateData();
    }

    function updateData() {
        updateEvents();
        updateWeather();
    }


    function updateEvents() {
        var dateMin = monthView.firstDisplayedDate();
        if (!dateMin) {
            // console.log('updateEvents', 'no dateMin');
            return;
        }
        var monthViewDateMax = monthView.lastDisplayedDate();
        var agendaViewDateMax = new Date(today).setDate(today.getDate() + 14);
        var dateMax;
        if (monthViewDate.getYear() == today.getYear() && monthViewDate.getMonth() == today.getMonth()) {
            dateMax = new Date(Math.max(monthViewDateMax, agendaViewDateMax));
        } else {
            dateMax = monthViewDateMax;
        }

        // console.log(dateMin);
        // console.log(dateMax);

        if (plasmoid.configuration.access_token) {
            var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
            var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];

            // console.log('updateEvents', dateMin, ' - ', dateMax);
            // console.log('calendarIdList', calendarIdList);
            // console.log('calendarList.length', calendarList.length);

            eventModel.eventsByCalendar = {};
            popup.visibleDateMin = dateMin
            popup.visibleDateMax = dateMax

            for (var i = 0; i < calendarIdList.length; i++) {
                (function(calendarId){
                    fetchGCalEvents({
                        calendarId: calendarId,
                        start: dateMin.toISOString(),
                        end: dateMax.toISOString(),
                        access_token: plasmoid.configuration.access_token,
                    }, function(err, data, xhr) {
                        if (err) {
                            if (typeof err === 'object') {
                                console.log('err: ', JSON.stringify(err, null, '\t'));
                            } else {
                                console.log('err: ', err);
                            }
                            if (xhr.status === 404) {
                                return;
                            }
                            return onGCalError(err);
                        }
                        // console.log('onGCalEvents', JSON.stringify(data, null, '\t'))

                        
                        eventModel.eventsByCalendar[calendarId] = data;
                        updateUI();
                    });
                })(calendarIdList[i]);
                
            }
        }
    }

    function updateWeather(force) {
        if (plasmoid.configuration.weather_city_id) {
            // update every hour
            var shouldUpdate = false;
            if (lastForecastAt) {
                var now = new Date();
                var currentHour = now.getHours();
                var lastUpdateHour = new Date(lastForecastAt).getHours();
                var beenOverAnHour = now.valueOf() - lastForecastAt >= 60 * 60 * 1000;
                if (lastUpdateHour != currentHour || beenOverAnHour) {
                    shouldUpdate = true;
                }
            } else {
                shouldUpdate = true;
            }
            
            if (force || shouldUpdate) {
                updateDailyWeather();

                if (popup.showMeteogram) {
                    updateHourlyWeather();
                }
            }
        }
    }

    function updateDailyWeather() {
        console.log('fetchDailyWeatherForecast', lastForecastAt, Date.now());
        WeatherApi.updateDailyWeather(function(err, data, xhr) {
            if (err) return console.log('fetchDailyWeatherForecast.err', err, xhr && xhr.status, data);
            console.log('fetchDailyWeatherForecast.response');
            // console.log('fetchDailyWeatherForecast.response', data);

            lastForecastAt = Date.now();
            dailyWeatherData = data;
            updateUI();
        });
    }

    function updateHourlyWeather() {
        console.log('fetchHourlyWeatherForecast', lastForecastAt, Date.now());
        WeatherApi.updateHourlyWeather(function(err, data, xhr) {
            if (err) return console.log('fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data);
            console.log('fetchHourlyWeatherForecast.response');
            // console.log('fetchHourlyWeatherForecast.response', data);

            lastForecastAt = Date.now();
            hourlyWeatherData = data;
            currentWeatherData = data.list[0];
            meteogramView.parseWeatherForecast(currentWeatherData, hourlyWeatherData);
        });
    }

    function updateUI() {
        // console.log('updateUI');
        var now = new Date();

        if (monthViewDate.getYear() == now.getYear() && monthViewDate.getMonth() == now.getMonth()) {
            agendaView.showNextNumDays = 14;
            agendaView.clipPastEvents = false;
        } else {
            agendaView.showNextNumDays = 0;
            agendaView.clipPastEvents = false;
        }

        var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];

        eventModel.eventsData = { items: [] }
        for (var calendarId in eventModel.eventsByCalendar) {
            calendarList.forEach(function(calendar){
                if (calendarId == calendar.id) {
                    eventModel.eventsByCalendar[calendarId].items.forEach(function(event){
                        event.backgroundColor = event.backgroundColor || calendar.backgroundColor;
                    });
                }
            });

            eventModel.eventsData.items = eventModel.eventsData.items.concat(eventModel.eventsByCalendar[calendarId].items);
            // console.log('updateUI', calendarId, eventModel.eventsByCalendar[calendarId].items.length, eventsData.items.length);
        }

        agendaView.parseGCalEvents(eventModel.eventsData);
        agendaView.parseWeatherForecast(dailyWeatherData);
        monthView.parseGCalEvents(eventModel.eventsData);
        scrollToSelection();
    }

    function onGCalError(err) {
        if (typeof err === 'object') {
            console.log('onGCalError: ', JSON.stringify(err, null, '\t'));
        } else {
            console.log('onGCalError: ', err);
        }
        
        updateAccessToken();
    }

    function fetchNewAccessToken(callback) {
        console.log('fetchNewAccessToken');
        var url = 'https://www.googleapis.com/oauth2/v4/token';
        Utils.post({
            url: url,
            data: {
                client_id: plasmoid.configuration.client_id,
                client_secret: plasmoid.configuration.client_secret,
                refresh_token: plasmoid.configuration.refresh_token,
                grant_type: 'refresh_token',
            },
        }, callback);
    }

    function updateAccessToken() {
        // console.log('access_token_expires_at', plasmoid.configuration.access_token_expires_at);
        // console.log('                    now', Date.now());
        // console.log('refresh_token', plasmoid.configuration.refresh_token);
        if (plasmoid.configuration.refresh_token) {
            console.log('fetchNewAccessToken');
            fetchNewAccessToken(function(err, data, xhr) {
                if (err || (!err && data && data.error)) {
                    return console.log('Error when using refreshToken:', err, data);
                }
                console.log('onAccessToken', data);
                data = JSON.parse(data);

                plasmoid.configuration.access_token = data.access_token;
                plasmoid.configuration.access_token_type = data.token_type;
                plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000;

                update();
            });
        }
    }

    function fetchGCalEvents(args, callback) {
        console.log('fetchGCalEvents', args.calendarId);
        var url = 'https://www.googleapis.com/calendar/v3';
        url += '/calendars/'
        url += encodeURIComponent(args.calendarId);
        url += '/events';
        url += '?timeMin=' + encodeURIComponent(args.start);
        url += '&timeMax=' + encodeURIComponent(args.end);
        url += '&singleEvents=' + encodeURIComponent('true');
        url += '&timeZone=' + encodeURIComponent('Etc/UTC');
        Utils.getJSON({
            url: url,
            headers: {
                "Authorization": "Bearer " + args.access_token,
            }
        }, function(err, data, xhr) {
            console.log('fetchGCalEvents.response', err, data, xhr.status);
            if (!err && data && data.error) {
                return callback(data, null, xhr);
            }
            callback(err, data, xhr);
        });
    }
}