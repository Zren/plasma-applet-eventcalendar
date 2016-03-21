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

Item {
    id: popup

    width: 800
    height: 500

    // Overload with config: plasmoid.configuration
    property variant config: { }

    property alias today: monthView.today
    property alias selectedDate: monthView.currentDate
    property alias monthViewDate: monthView.displayedDate
    property variant eventsData: { "items": [] }
    property variant weatherData: { "list": [] }
    property variant lastForecastAt: null

    onSelectedDateChanged: {
        console.log('onSeletedDateChanged', selectedDate)
    }

    onMonthViewDateChanged: {
        console.log('onMonthViewDateChanged', monthViewDate)
        updateEvents();
    }


    // Debugging
    Rectangle {
        visible: !root
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }

    Grid {
        columns: 2
        rows: 2

        Item {
            width: popup.width / 2
            height: popup.height / 5

            Rectangle {
                color: PlasmaCore.ColorScope.backgroundColor
                anchors.fill: parent
            }
        }
        Item {
            width: popup.width / 2
            height: popup.height / 5

            TimerView {
                id: timerView
            }
        }

        Item {
            width: popup.width / 2
            height: popup.height * 4/5

            AgendaView {
                id: agendaView
            }
        }
        Item {
            width: popup.width / 2
            height: popup.height * 4/5
            
            MonthView {
                id: monthView
                borderOpacity: 0.25
                showWeekNumbers: false
                width: popup.width / 2
                height: popup.height * 4/5
                today: new Date()

                function parseGCalEvents(data) {
                    if (!(data && data.items))
                        return;

                    // https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/daysmodel.h
                    for (var j = 0; j < data.items.length; j++) {
                        var eventItem = data.items[j];
                        var month = eventItem.start.dateTime.getMonth();
                        var date = eventItem.start.dateTime.getDate();
                        for (var i = 0; i < monthView.daysModel2.count; i++) {
                            var dayData = monthView.daysModel2.get(i);
                            if (month+1 == dayData.monthNumber && date == dayData.dayNumber) {
                                // console.log(dayData.monthNumber, dayData.dayNumber, eventItem.start.dateTime, eventItem.summary);
                                monthView.daysModel2.setProperty(i, 'showEventBadge', true);
                                break;
                            }
                        }
                    }
                }
            }
        }
    }

    Component.onCompleted: {
        update();
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

        eventsData = { "items": [] }
        updateUI();

        if (config && config.access_token) {
            fetchGCalEvents({
                start: dateMin.toISOString(),
                end: dateMax.toISOString(),
                access_token: config.access_token,
            }, function(err, data, xhr) {
                if (err) {
                    return onGCalError(err);
                }

                eventsData = data;
                updateUI();
            });
        }
    }

    function updateWeather() {
        if (config && config.weather_city_id2) {
            // rate limit 1 request / hour
            if (!lastForecastAt && Date.now() - lastForecastAt >= 60 * 60 * 1000) {
                console.log('fetchWeatherForecast', lastForecastAt, Date.now());
                fetchWeatherForecast({
                    app_id: config.weather_app_id2,
                    city_id: config.weather_city_id2,
                }, function(err, data, xhr) {
                    if (err) {
                        return console.log('onWeatherError', err);
                    }

                    lastForecastAt = Date.now();
                    weatherData = data;
                    updateUI();
                });
            }
        }
    }

    function updateUI() {
        var today = new Date();

        if (monthViewDate.getYear() == today.getYear() && monthViewDate.getMonth() == today.getMonth()) {
            agendaView.showNextNumDays = 14;
            agendaView.clipPastEvents = true;
        } else {
            agendaView.showNextNumDays = 0;
            agendaView.clipPastEvents = false;
        }

        agendaView.parseGCalEvents(eventsData);
        agendaView.parseWeatherForecast(weatherData);
        monthView.parseGCalEvents(eventsData);
    }

    function onGCalError(err) {
        if (typeof err === 'object') {
            console.log('onGCalError: ', JSON.stringify(err, null, '\t'));
        } else {
            console.log('onGCalError: ', err);
        }
        
        console.log('access_token_expires_at', config.access_token_expires_at);
        console.log('                    now', Date.now());
        console.log('refresh_token', config.refresh_token);
        if (config.refresh_token) {
            console.log('fetchNewAccessToken');
            fetchNewAccessToken(function(err, data, xhr) {
                if (err || (!err && data && data.error)) {
                    return console.log('Error when using refreshToken:', err, data);
                }

                config.access_token = data.access_token;
                config.access_token_type = data.token_type;
                config.access_token_expires_at = Date.now() + data.expires_in * 1000;
                config.refresh_token = data.refresh_token;

                update();
            });
        }
    }

    function fetchNewAccessToken(callback) {
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

    function fetchGCalEvents(args, callback) {
        var url = 'https://www.googleapis.com/calendar/v3';
        url += '/calendars/primary/events';
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
            if (!err && data && data.error) {
                return callback(data, null, xhr);
            }
            callback(err, data, xhr);
        });
    }

    function fetchWeatherForecast(args, callback) {
        if (!args.app_id) return callback('OpenWeatherMap AppId not set');
        if (!args.city_id) return callback('OpenWeatherMap CityId not set');
        
        var url = 'http://api.openweathermap.org/data/2.5/';
        url += 'forecast/daily?id=' + args.city_id;
        url += '&units=metric';
        url += '&appid=' + args.app_id;
        Utils.getJSON(url, callback);
    }
}