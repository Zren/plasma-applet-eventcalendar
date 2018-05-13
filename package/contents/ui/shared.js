.pragma library

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
