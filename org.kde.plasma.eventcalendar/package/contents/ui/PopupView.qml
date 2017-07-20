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
    property bool singleColumn: !showAgenda || !showCalendar
    property bool singleColumnFullHeight: !plasmoid.configuration.twoColumns && showAgenda && showCalendar
    property bool twoColumns: plasmoid.configuration.twoColumns && showAgenda && showCalendar

    Layout.minimumWidth: {
        if (twoColumns) {
            // return (400 + 10 + 400) * units.devicePixelRatio
            return units.gridUnit * 28
        } else {
            // return 400 * units.devicePixelRatio
            return units.gridUnit * 14
        }
    }
    Layout.preferredWidth: {
        if (twoColumns) {
            return (400 + 10 + 400) * units.devicePixelRatio + padding * 2
        } else {
            return 400 * units.devicePixelRatio + padding * 2
        }
    }
    // Layout.maximumWidth: plasmoid.screenGeometry.width

    // Layout.minimumHeight: 400 * units.devicePixelRatio
    Layout.minimumHeight: units.gridUnit * 14
    Layout.preferredHeight: {
        if (singleColumnFullHeight) {
            return plasmoid.screenGeometry.height
        } else if (singleColumn) {
            var h = 400 // showAgenda || showCalendar
            if (showMeteogram) {
                h += 10 + 100
            }
            if (showTimer) {
                h += 10 + 100
            }
            return h * units.devicePixelRatio + padding * 2
        } else { // twoColumns
            var h = 400 // showAgenda || showCalendar
            if (showMeteogram || showTimer) {
                h += 10 + 100
            }
            return h * units.devicePixelRatio + padding * 2
        }
    }
    // Layout.maximumHeight: plasmoid.screenGeometry.height

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
            // logger.debug('onDateSelected', selectedDate)
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
        logger.debug('onMonthViewDateChanged', monthViewDate)
        var startOfMonth = new Date(monthViewDate);
        startOfMonth.setDate(1);
        agendaView.currentMonth = new Date(startOfMonth);
        if (cfg_agenda_scroll_on_monthchange) {
            selectedDate = startOfMonth;
        }
        updateEvents();
    }

    onStateChanged: {
        // logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
    }
    states: [
        State {
            name: "calendar"
            when: !popup.showAgenda && popup.showCalendar && !popup.showMeteogram && !popup.showTimer

            PropertyChanges { target: popup
                // Use the same size as the digitalclock popup
                // since we don't need more space to fit more agenda items.
                Layout.preferredWidth: 378 * units.devicePixelRatio
                Layout.preferredHeight: 378 * units.devicePixelRatio
            }
            PropertyChanges { target: monthView
                Layout.preferredWidth: -1
                Layout.preferredHeight: -1
            }
        },
        State {
            name: "twoColumns+agenda+month"
            when: popup.twoColumns && popup.showAgenda && popup.showCalendar && !popup.showMeteogram && !popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 1
            }
        },
        State {
            name: "twoColumns+meteogram+agenda+month"
            when: popup.twoColumns && popup.showAgenda && popup.showCalendar && popup.showMeteogram && !popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
            PropertyChanges { target: meteogramView
                Layout.columnSpan: 2
            }
        },
        State {
            name: "twoColumns+timer+agenda+month"
            when: popup.twoColumns && popup.showAgenda && popup.showCalendar && !popup.showMeteogram && popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
            AnchorChanges { target: timerView
                anchors.top: widgetGrid.top
                anchors.right: widgetGrid.right
            }
            AnchorChanges { target: agendaView
                anchors.top: widgetGrid.top
                anchors.left: widgetGrid.left
                anchors.bottom: widgetGrid.bottom
            }
            AnchorChanges { target: monthView
                anchors.top: timerView.bottom
                anchors.right: widgetGrid.right
                anchors.bottom: widgetGrid.bottom
            }
            PropertyChanges { target: monthView
                anchors.topMargin: widgetGrid.rowSpacing
            }
        },
        State {
            name: "twoColumns+meteogram+timer+agenda+month"
            when: popup.twoColumns && popup.showAgenda && popup.showCalendar && popup.showMeteogram && popup.showTimer

            PropertyChanges { target: widgetGrid
                columns: 2
                rows: 2
            }
        },
        State {
            name: "singleColumnFullHeight"
            when: !popup.twoColumns && popup.showAgenda && popup.showCalendar

            PropertyChanges { target: widgetGrid
                columns: 1
            }
            PropertyChanges { target: meteogramView
                Layout.maximumHeight: popup.topRowHeight * 1.5 // 150%
            }
            PropertyChanges { target: timerView
                Layout.maximumHeight: popup.topRowHeight
            }
            PropertyChanges { target: agendaView
                // Layout.minimumHeight: popup.bottomRowHeight
                Layout.preferredHeight: popup.bottomRowHeight
            }
            PropertyChanges { target: monthView
                Layout.minimumHeight: popup.bottomRowHeight
                Layout.preferredHeight: popup.bottomRowHeight
                Layout.maximumHeight: popup.bottomRowHeight
            }
        },
        // State {
        //     name: "singleColumnFullHeight"
        //     when: !popup.twoColumns && popup.showAgenda && popup.showCalendar

        //     PropertyChanges { target: widgetGrid
        //         columns: 1
        //     }
        //     PropertyChanges { target: meteogramView
        //         Layout.maximumHeight: popup.topRowHeight
        //         Layout.row: 3
        //     }
        //     PropertyChanges { target: timerView
        //         Layout.maximumHeight: popup.topRowHeight
        //         Layout.row: 0
        //     }
        //     PropertyChanges { target: agendaView
        //         Layout.preferredHeight: popup.bottomRowHeight
        //         Layout.fillHeight: true
        //         Layout.row: 2
        //     }
        //     PropertyChanges { target: monthView
        //         Layout.minimumHeight: popup.bottomRowHeight
        //         Layout.preferredHeight: popup.bottomRowHeight
        //         Layout.maximumHeight: popup.bottomRowHeight
        //         Layout.row: 1
        //     }
        // },
        State {
            name: "singleColumn"
            when: !popup.showAgenda || !popup.showCalendar

            PropertyChanges { target: widgetGrid
                columns: 1
            }
            PropertyChanges { target: meteogramView
                Layout.maximumHeight: popup.topRowHeight * 1.5 // 150%
            }
            PropertyChanges { target: timerView
                Layout.maximumHeight: popup.topRowHeight
            }
        }
    ]

    ColumnLayout {
        anchors.fill: parent

        GridLayout {
            id: widgetGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            columnSpacing: popup.spacing
            rowSpacing: popup.spacing
            onColumnsChanged: {
                // logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
            }
            onRowsChanged: {
                // logger.debug(popup.state, widgetGrid.columns, widgetGrid.rows)
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
                        text: i18n("Weather not configured.\nGo to Weather in the config and set your city,\nand/or disable the meteogram to hide this area.")
                        anchors.centerIn: parent
                        width: Math.min(parent.width, implicitWidth)
                        height: Math.min(parent.height, implicitHeight)
                        fontSizeMode: Text.Fit
                    }
                }
            }

            TimerView {
                id: timerView
                visible: showTimer
                Layout.fillWidth: true
                Layout.minimumHeight: Math.max(popup.topRowHeight, implicitHeight)
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
                    // logger.debug('onNewEventFormOpened')
                    if (plasmoid.configuration.access_token) {
                        var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
                        var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
                        // logger.debug('calendarList', JSON.stringify(calendarList, null, '\t'))
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
                    // logger.debug('onSubmitNewEventForm', calendarId)
                    if (plasmoid.configuration.access_token) {
                        logger.debug(calendarId, calendarId.calendarId)
                        calendarId = calendarId.calendarId ? calendarId.calendarId : calendarId
                        eventModel.createEvent(calendarId, date, text)
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
                        // logger.debug(eventItemStartDate, eventItemEndDate)
                        for (var i = 0; i < monthView.daysModel.count; i++) {
                            var dayData = monthView.daysModel.get(i);
                            var dayDataDate = new Date(dayData.yearNumber, dayData.monthNumber - 1, dayData.dayNumber);
                            if (eventItemStartDate <= dayDataDate && dayDataDate <= eventItemEndDate) {
                                // logger.debug('\t', dayDataDate)
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
                    // logger.debug('Popup.monthView.onDoubleClicked', date);
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
            logger.debug('today = new Date()')
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
        logger.debug('update')
        updateData();
    }

    function updateData() {
        logger.debug('updateData')
        updateEvents();
        updateWeather();
    }

    function updateEvents() {
        updateEventsTimer.restart()
    }
    Timer {
        id: updateEventsTimer
        interval: 200
        onTriggered: deferredUpdateEvents()
    }

    Connections {
        target: eventModel
        onCalendarFetched: {
            logger.log('onCalendarFetched', calendarId)
            // logger.debug('onCalendarFetched', calendarId, JSON.stringify(data, null, '\t'))
            popup.deferredUpdateUI()
        }
        onAllDataFetched: {
            // logger.log('onAllDataFetched')
            popup.updateUI()
        }
        onEventCreated: {
            logger.log('onEventCreated', calendarId, JSON.stringify(data, null, '\t'))
            popup.updateUI()
        }
        onEventUpdated: {
            logger.log('onEventUpdated', calendarId, eventId, JSON.stringify(data, null, '\t'))
            popup.updateUI()
        }
        onEventDeleted: {
            logger.log('onEventDeleted', calendarId, eventId, JSON.stringify(data, null, '\t'))
            popup.updateUI()
        }
    }
    function deferredUpdateEvents() {
        var dateMin = monthView.firstDisplayedDate();
        if (!dateMin) {
            // logger.log('updateEvents', 'no dateMin');
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


        popup.visibleDateMin = dateMin
        popup.visibleDateMax = dateMax
        eventModel.fetchAllEvents(dateMin, dateMax)

        // logger.debug(dateMin);
        // logger.debug(dateMax);

        /*
        if (plasmoid.configuration.access_token) {
            var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
            var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];

            // logger.debug('updateEvents', dateMin, ' - ', dateMax);
            // logger.debug('calendarIdList', calendarIdList);
            // logger.debug('calendarList.length', calendarList.length);

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
                                logger.debug('err: ', JSON.stringify(err, null, '\t'));
                            } else {
                                logger.debug('err: ', err);
                            }
                            if (xhr.status === 404) {
                                return;
                            }
                            return onGCalError(err);
                        }
                        // logger.debug('onGCalEvents', JSON.stringify(data, null, '\t'))

                        
                        eventModel.eventsByCalendar[calendarId] = data;
                        updateUI();
                    });
                })(calendarIdList[i]);
                
            }
        }
        */
    }

    function updateWeather(force) {
        if (WeatherApi.weatherIsSetup()) {
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
                updateWeatherTimer.restart()
            }
        }
    }
    Timer {
        id: updateWeatherTimer
        interval: 100
        onTriggered: deferredUpdateWeather()
    }
    function deferredUpdateWeather() {
        updateDailyWeather();

        if (popup.showMeteogram) {
            updateHourlyWeather();
        }
    }

    function updateDailyWeather() {
        logger.debug('fetchDailyWeatherForecast', lastForecastAt, Date.now());
        WeatherApi.updateDailyWeather(function(err, data, xhr) {
            if (err) return logger.log('fetchDailyWeatherForecast.err', err, xhr && xhr.status, data);
            logger.debugJSON('fetchDailyWeatherForecast.response', data);

            lastForecastAt = Date.now();
            dailyWeatherData = data;
            updateUI();
        });
    }

    function updateHourlyWeather() {
        logger.debug('fetchHourlyWeatherForecast', lastForecastAt, Date.now());
        WeatherApi.updateHourlyWeather(function(err, data, xhr) {
            if (err) return logger.log('fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data);
            logger.debugJSON('fetchHourlyWeatherForecast.response', data);

            lastForecastAt = Date.now();
            hourlyWeatherData = data;
            currentWeatherData = data.list[0];
            meteogramView.parseWeatherForecast(currentWeatherData, hourlyWeatherData);
        });
    }

    Timer {
        id: updateUITimer
        interval: 100
        onTriggered: popup.updateUI()
    }
    function deferredUpdateUI() {
        updateUITimer.restart()
    }

    function updateUI() {
        // logger.debug('updateUI');
        var now = new Date();

        if (updateUITimer.running) {
            updateUITimer.running = false
        }

        if (monthViewDate.getYear() == now.getYear() && monthViewDate.getMonth() == now.getMonth()) {
            agendaView.showNextNumDays = 14;
            agendaView.clipPastEvents = false;
        } else {
            agendaView.showNextNumDays = 0;
            agendaView.clipPastEvents = false;
        }

        eventModel.parseGCalEvents()
        agendaView.parseGCalEvents(eventModel.eventsData);
        agendaView.parseWeatherForecast(dailyWeatherData);
        monthView.parseGCalEvents(eventModel.eventsData);
        scrollToSelection();
    }

    function onGCalError(err) {
        if (typeof err === 'object') {
            logger.log('onGCalError: ', JSON.stringify(err, null, '\t'));
        } else {
            logger.log('onGCalError: ', err);
        }
        
        updateAccessToken();
    }

    function fetchNewAccessToken(callback) {
        logger.debug('fetchNewAccessToken');
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
        // logger.debug('access_token_expires_at', plasmoid.configuration.access_token_expires_at);
        // logger.debug('                    now', Date.now());
        // logger.debug('refresh_token', plasmoid.configuration.refresh_token);
        if (plasmoid.configuration.refresh_token) {
            logger.debug('fetchNewAccessToken');
            fetchNewAccessToken(function(err, data, xhr) {
                if (err || (!err && data && data.error)) {
                    return logger.log('Error when using refreshToken:', err, data);
                }
                logger.debug('onAccessToken', data);
                data = JSON.parse(data);

                plasmoid.configuration.access_token = data.access_token;
                plasmoid.configuration.access_token_type = data.token_type;
                plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000;

                update();
            });
        }
    }

    function fetchGCalEvents(args, callback) {
        logger.debug('fetchGCalEvents', args.calendarId);
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
            logger.debug('fetchGCalEvents.response', args.calendarId, err, data, xhr.status);
            if (!err && data && data.error) {
                return callback(data, null, xhr);
            }
            callback(err, data, xhr);
        });
    }
}
