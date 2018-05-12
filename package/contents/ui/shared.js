.import "./lib/Requests.js" as Requests

function openGoogleCalendarNewEventUrl(date) {
    function dateString(year, month, day) {
        var s = '' + year;
        s += (month < 10 ? '0' : '') + month;
        s += (day < 10 ? '0' : '') + day;
        return s;
    }

    var nextDay = new Date(date.getFullYear(), date.getMonth(), date.getDate() + 1)

    var url = 'https://calendar.google.com/calendar/render?action=TEMPLATE'
    var startDate = dateString(date.getFullYear(), date.getMonth() + 1, date.getDate())
    var endDate = dateString(nextDay.getFullYear(), nextDay.getMonth() + 1, nextDay.getDate())
    url += '&dates=' + startDate + '/' + endDate
    Qt.openUrlExternally(url)
}

function createGCalEvent(args, callback) {
    // https://www.googleapis.com/calendar/v3/calendars/calendarId/events/quickAdd
    var url = 'https://www.googleapis.com/calendar/v3';
    url += '/calendars/'
    url += encodeURIComponent(args.calendarId);
    url += '/events/quickAdd';
    url += '?text=' + encodeURIComponent(args.text);
    Requests.postJSON({
        url: url,
        headers: {
            "Authorization": "Bearer " + args.access_token,
        }
    }, function(err, data, xhr) {
        console.log('createGCalEvent.response', err, data, xhr.status);
        if (!err && data && data.error) {
            return callback(data, null, xhr);
        }
        callback(err, data, xhr);
    });
}

function openOpenWeatherMapCityUrl(cityId) {
    var url = 'http://openweathermap.org/city/';
    url += cityId;
    Qt.openUrlExternally(url);
}

function fetchHourlyWeatherForecast(args, callback) {
    if (!args.app_id) return callback('OpenWeatherMap AppId not set');
    if (!args.city_id) return callback('OpenWeatherMap CityId not set');
    
    var url = 'http://api.openweathermap.org/data/2.5/';
    url += 'forecast?id=' + args.city_id;
    url += '&units=' + (args.units || 'metric');
    url += '&appid=' + args.app_id;
    Requests.getJSON(url, callback);
}

function fetchDailyWeatherForecast(args, callback) {
    console.log('fetchWeatherForecast');
    if (!args.app_id) return callback('OpenWeatherMap AppId not set');
    if (!args.city_id) return callback('OpenWeatherMap CityId not set');
    
    var url = 'http://api.openweathermap.org/data/2.5/';
    url += 'forecast/daily?id=' + args.city_id;
    url += '&units=' + (args.units || 'metric');
    url += '&appid=' + args.app_id;
    Requests.getJSON(url, callback);
}

// http://openweathermap.org/weather-conditions
var weatherIconMap = {
    '01d': 'weather-clear',
    '02d': 'weather-few-clouds',
    '03d': 'weather-clouds',
    '04d': 'weather-overcast',
    '09d': 'weather-showers-scattered',
    '10d': 'weather-showers',
    '11d': 'weather-storm',
    '13d': 'weather-snow',
    '50d': 'weather-fog',
    '01n': 'weather-clear-night',
    '02n': 'weather-few-clouds-night',
    '03n': 'weather-clouds-night',
    '04n': 'weather-overcast',
    '09n': 'weather-showers-scattered-night',
    '10n': 'weather-showers-night',
    '11n': 'weather-storm-night',
    '13n': 'weather-snow',
    '50n': 'weather-fog',
};

function isSameDate(a, b) {
    // console.log('isSameDate', a, b)
    return a.getFullYear() == b.getFullYear() && a.getMonth() == b.getMonth() && a.getDate() == b.getDate();
}
function isDateEarlier(a, b) {
    var c = new Date(b.getFullYear(), b.getMonth(), b.getDate()); // midnight of date b
    return a < c;
}
function isDateAfter(a, b) {
    var c = new Date(b.getFullYear(), b.getMonth(), b.getDate() + 1); // midnight of next day after b
    return a >= c;
}

function formatEventTime(dateTime, args) {
    var clock24h = args && args.clock24h;
    var timeFormat;
    if (clock24h) {
        if (dateTime.getMinutes() == 0) {
            timeFormat = i18nc("event time on the hour (24 hour clock)", "h")
        } else {
            timeFormat = i18n("h:mm")
        }
    } else { // 12h
        if (dateTime.getMinutes() == 0) {
            timeFormat = i18nc("event time on the hour (12 hour clock)", "h AP")
        } else {
            timeFormat = i18n("h:mm AP")
        }
    }
    return Qt.formatDateTime(dateTime, timeFormat)
}

function formatEventDateTime(dateTime, args) {
    var shortDateFormat = i18nc("short month+date format", "MMM d");
    var dateStr = Qt.formatDateTime(dateTime, shortDateFormat);
    var timeStr = formatEventTime(dateTime, args);
    return i18nc("date (%1) with time (%2)", "%1, %2", dateStr, timeStr);
}

function formatEventDuration(event, args) {
    var relativeDate = args && args.relativeDate;
    var clock24h = args && args.clock24h;
    var startTime = event.start.dateTime;
    var endTime = event.end.dateTime;
    var shortDateFormat = i18nc("short month+date format", "MMM d");

    if (event.start.date) {
        // GCal ends all day events at midnight, which is technically the next day.
        // Humans consider the event to end at 23:59 the day before though.
        var dayBefore = new Date(endTime);
        dayBefore.setDate(dayBefore.getDate() - 1);
        if (isSameDate(startTime, dayBefore)) {
            return i18n("All Day");
        } else {
            var startStr = Qt.formatDateTime(startTime, shortDateFormat);
            var endStr = Qt.formatDateTime(dayBefore, shortDateFormat);
            return i18nc("from date/time %1 until date/time %2", "%1 - %2", startStr, endStr);
        }
    } else {
        var startStr;
        if (!relativeDate || !isSameDate(startTime, relativeDate)) {
            startStr = formatEventDateTime(startTime, args); // MMM d, h:mm AP
        } else {
            startStr = formatEventTime(startTime, args); // h:mm AP
        }

        if (startTime.valueOf() == endTime.valueOf()) {
            return startStr; // Don't need the end time
        }

        var endStr;
        if (isSameDate(startTime, endTime)) {
            endStr = formatEventTime(endTime, args); // MMM d, h:mm AP - h:mm AP
        } else {
            // !isSameDate, so we need to add the date
            endStr = formatEventDateTime(endTime, args); // MMM d, h:mm AP - MMM d, h:mm AP
        }
        return i18nc("from date/time %1 until date/time %2", "%1 - %2", startStr, endStr);
    }
}
