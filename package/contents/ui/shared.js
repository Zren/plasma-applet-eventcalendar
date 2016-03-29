.import "utils.js" as Utils

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
    https://www.googleapis.com/calendar/v3/calendars/calendarId/events/quickAdd
    var url = 'https://www.googleapis.com/calendar/v3';
    url += '/calendars/'
    url += encodeURIComponent(args.calendarId);
    url += '/events/quickAdd';
    url += '?text=' + encodeURIComponent(args.text);
    Utils.postJSON({
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
