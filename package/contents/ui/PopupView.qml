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
import "debugfixtures.js" as DebugFixtures

Item {
    id: popup

    // use Layout.prefferedHeight instead of height so that the plasmoid resizes.
    width: columnWidth + 10 + columnWidth
    Layout.preferredHeight: bottomRowHeight
    property int topRowHeight: 100
    property int bottomRowHeight: 400
    property int columnWidth: 400
    function updateHeight() {
        var rows = Math.ceil(widgetGrid.visibleChildren.length / widgetGrid.columns)
        Layout.preferredHeight = rows * topRowHeight + (rows > 0 ? 10 : 0) + bottomRowHeight

        // Debugging with qmlviewer
        if (typeof root === 'undefined') {
            height = Layout.preferredHeight
        }
    }

    // Overload with config: plasmoid.configuration
    property variant config: { }
    property bool cfg_clock_24h: false
    property bool cfg_widget_show_spacer: true
    property bool cfg_widget_show_meteogram: true
    property bool cfg_widget_show_timer: true
    property bool cfg_agenda_scroll_on_select: true
    property bool cfg_agenda_scroll_on_monthchange: false
    property bool cfg_agenda_weather_show_icon: false
    property int cfg_agenda_weather_icon_height: 24
    property bool cfg_agenda_weather_show_text: false
    property bool cfg_agenda_breakup_multiday_events: true
    property bool cfg_month_show_border: true
    
    property alias agendaListView: agendaView.agendaListView
    property alias today: monthView.today
    property alias selectedDate: monthView.currentDate
    property alias monthViewDate: monthView.displayedDate
    property variant eventsData: { "items": [] }
    property variant eventsByCalendar: { "": { "items": [] } }
    property variant dailyWeatherData: { "list": [] }
    property variant hourlyWeatherData: { "list": [] }
    property variant currentWeatherData: null
    property variant lastForecastAt: null

    onSelectedDateChanged: {
        console.log('onSeletedDateChanged', selectedDate)
        scrollToSelection()
    }
    function scrollToSelection() {
        if (!cfg_agenda_scroll_on_select)
            return;
        if (true) {
            agendaView.scrollToDate(selectedDate)
        } else {
            agendaView.scrollToTop()
        }
    }

    onMonthViewDateChanged: {
        console.log('onMonthViewDateChanged', monthViewDate)
        if (cfg_agenda_scroll_on_monthchange) {
            var startOfMonth = new Date(monthViewDate);
            startOfMonth.setDate(1);
            selectedDate = startOfMonth;
        }
        updateEvents();
    }


    // Debugging
    Rectangle {
        visible: typeof root === 'undefined'
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }

    Column {
        spacing: 10
        Grid {
            id: widgetGrid
            columns: 2
            spacing: 10

            Item {
                id: spacerItem
                visible: cfg_widget_show_spacer
                width: columnWidth
                height: topRowHeight
            }
            Item {
                id: meteogramItem
                visible: cfg_widget_show_meteogram
                width: columnWidth
                height: topRowHeight

                ForecastGraph {
                    id: meteogramView
                    width: columnWidth
                    height: topRowHeight
                }
            }
            Item {
                id: timerItem
                visible: cfg_widget_show_timer
                width: columnWidth
                height: topRowHeight

                TimerView {
                    id: timerView
                }
            }
        }
        Grid {
            columns: 2
            spacing: 10

            Item {
                width: columnWidth
                height: bottomRowHeight

                AgendaView {
                    id: agendaView

                    cfg_agenda_breakup_multiday_events: popup.cfg_agenda_breakup_multiday_events
                    cfg_agenda_weather_show_icon: popup.cfg_agenda_weather_show_icon
                    cfg_agenda_weather_icon_height: popup.cfg_agenda_weather_icon_height
                    cfg_agenda_weather_show_text: popup.cfg_agenda_weather_show_text

                    onNewEventFormOpened: {
                        console.log('onNewEventFormOpened')
                        if (config && config.access_token) {
                            var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
                            var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
                            // console.log('calendarList', JSON.stringify(calendarList, null, '\t'))
                            var list = []
                            calendarList.forEach(function(calendar){
                                if (calendar.accessRole == 'owner') {
                                    list.push({
                                        'calendarId': calendar.id,
                                        'text': calendar.summary,
                                    })
                                }
                            });
                            newEventCalendarId.model = list
                        }
                    }
                    onSubmitNewEventForm: {
                        console.log('onSubmitNewEventForm', calendarId)
                        if (config && config.access_token) {
                            var calendarId2 = calendarId.calendarId ? calendarId.calendarId : calendarId
                            var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];
                            var dateString = date.getFullYear() + '-' + (date.getMonth()+1) + '-' + date.getDate()
                            console.log('text', dateString + ' ' + text)
                            Shared.createGCalEvent({
                                access_token: config.access_token,
                                calendarId: calendarId2,
                                text: dateString + ' ' + text,
                            }, function(err, data) {
                                // console.log(err, JSON.stringify(data, null, '\t'));
                                var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
                                if (calendarIdList.indexOf(calendarId2) >= 0) {
                                    eventsByCalendar[calendarId2].items.push(data);
                                    updateUI()
                                }
                            })
                        }
                    }
                }

                PlasmaComponents.Button {
                    iconSource: 'view-refresh'
                    width: 26
                    anchors.bottom: parent.bottom
                    anchors.right: parent.right
                    onClicked: {
                        updateEvents()
                        updateWeather(true)
                    }
                }
            }
            Item {
                width: columnWidth
                height: bottomRowHeight
                
                MonthView {
                    id: monthView
                    borderOpacity: cfg_month_show_border ? 0.25 : 0
                    showWeekNumbers: false
                    width: columnWidth
                    height: bottomRowHeight

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
                            var month = eventItem.start.dateTime.getMonth();
                            var date = eventItem.start.dateTime.getDate();
                            for (var i = 0; i < monthView.daysModel.count; i++) {
                                var dayData = monthView.daysModel.get(i);
                                if (month+1 == dayData.monthNumber && date == dayData.dayNumber) {
                                    // console.log(dayData.monthNumber, dayData.dayNumber, eventItem.start.dateTime, eventItem.summary);
                                    monthView.daysModel.setProperty(i, 'showEventBadge', true);
                                    var events = dayData.events || [];
                                    events.append(eventItem);
                                    monthView.daysModel.setProperty(i, 'events', events);
                                    break;
                                }
                            }
                        }
                    }

                    onDayDoubleClicked: {
                        var date = new Date(dayData.yearNumber, dayData.monthNumber-1, dayData.dayNumber);
                        console.log('Popup.monthView.onDoubleClicked', date);
                        if (true) {
                            // cfg_month_day_doubleclick == "browser_newevent"
                            Shared.openGoogleCalendarNewEventUrl(date);
                        }
                        
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        delete eventsByCalendar[''] // Is there really no way to initialize an empty JSON object?
        if (typeof root === 'undefined') {
            today = new Date();
        }
        updateHeight()
        update();
        if (typeof root === 'undefined') {
            // eventsByCalendar['debug'] = DebugFixtures.getEventData();
            eventsData = DebugFixtures.getEventData();
            // updateUI();
            // agendaView.parseGCalEvents(eventsData);
            // monthView.parseGCalEvents(eventsData);
        }
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
            console.log('updateEvents', 'no dateMin');
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

        if (config && config.access_token) {
            var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary'];
            var calendarList = plasmoid.configuration.calendar_list ? JSON.parse(Qt.atob(plasmoid.configuration.calendar_list)) : [];

            console.log('updateEvents', dateMin, ' - ', dateMax);
            console.log('calendarIdList', calendarIdList);
            console.log('calendarList.length', calendarList.length);

            eventsByCalendar = {};

            for (var i = 0; i < calendarIdList.length; i++) {
                (function(calendarId){
                    fetchGCalEvents({
                        calendarId: calendarId,
                        start: dateMin.toISOString(),
                        end: dateMax.toISOString(),
                        access_token: config.access_token,
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

                        
                        eventsByCalendar[calendarId] = data;
                        updateUI();
                    });
                })(calendarIdList[i]);
                
            }
        }
    }

    function updateWeather(force) {
        if (config && config.weather_city_id) {
            // rate limit 1 update / hour
            var timeSinceUpdate = lastForecastAt ? Date.now() - lastForecastAt : Date.now();
            console.log('updateWeather.timeSinceUpdate', timeSinceUpdate)
            if (force || timeSinceUpdate >= 60 * 60 * 1000) {
                updateDailyWeather();

                if (popup.cfg_widget_show_meteogram) {
                    updateHourlyWeather();
                }
            }
        }
    }

    function updateDailyWeather() {
        console.log('fetchDailyWeatherForecast', lastForecastAt, Date.now());
        Shared.fetchDailyWeatherForecast({
            app_id: config.weather_app_id,
            city_id: config.weather_city_id,
        }, function(err, data, xhr) {
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
        Shared.fetchHourlyWeatherForecast({
            app_id: config.weather_app_id,
            city_id: config.weather_city_id,
        }, function(err, data, xhr) {
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
        console.log('updateUI');
        var now = new Date();

        if (monthViewDate.getYear() == now.getYear() && monthViewDate.getMonth() == now.getMonth()) {
            agendaView.showNextNumDays = 14;
            agendaView.clipPastEvents = true;
        } else {
            agendaView.showNextNumDays = 0;
            agendaView.clipPastEvents = false;
        }

        var calendarList = config && config.calendar_list ? JSON.parse(Qt.atob(config.calendar_list)) : [];

        eventsData = { items: [] }
        for (var calendarId in eventsByCalendar) {
            calendarList.forEach(function(calendar){
                if (calendarId == calendar.id) {
                    eventsByCalendar[calendarId].items.forEach(function(event){
                        event.backgroundColor = event.backgroundColor || calendar.backgroundColor;
                    });
                }
            });

            eventsData.items = eventsData.items.concat(eventsByCalendar[calendarId].items);
            console.log('updateUI', calendarId, eventsByCalendar[calendarId].items.length, eventsData.items.length);
        }

        agendaView.cfg_clock_24h = config ? config.clock_24h : false;
        agendaView.parseGCalEvents(eventsData);
        agendaView.parseWeatherForecast(dailyWeatherData);
        monthView.parseGCalEvents(eventsData);
        updateHeight()
        // scrollToSelection();
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
                client_id: config.client_id,
                client_secret: config.client_secret,
                refresh_token: config.refresh_token,
                grant_type: 'refresh_token',
            },
        }, callback);
    }

    function updateAccessToken() {
        console.log('access_token_expires_at', config.access_token_expires_at);
        console.log('                    now', Date.now());
        console.log('refresh_token', config.refresh_token);
        if (config.refresh_token) {
            console.log('fetchNewAccessToken');
            fetchNewAccessToken(function(err, data, xhr) {
                if (err || (!err && data && data.error)) {
                    return console.log('Error when using refreshToken:', err, data);
                }
                console.log('onAccessToken', data);
                data = JSON.parse(data);

                config.access_token = data.access_token;
                config.access_token_type = data.token_type;
                config.access_token_expires_at = Date.now() + data.expires_in * 1000;

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