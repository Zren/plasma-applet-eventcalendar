.import "utils.js" as Utils

var googleAuthToken = '';
var openweathermapCityId = '';
var openweathermapAppId = '';


function fetchGCalEvents(callback) {
    var url = 'https://www.googleapis.com/calendar/v3';
    url += '/calendars/primary/events';
    url += '?timeMin=' + encodeURIComponent('2016-03-01T0:00:00-00:00');
    url += '&timeMax=' + encodeURIComponent('2016-04-01T0:00:00-00:00');
    url += '&singleEvents=' + encodeURIComponent('true');
    url += '&timeZone=' + encodeURIComponent('Etc/UTC');
    Utils.getJSON({
        url: url,
        headers: {
            "Authorization": "Bearer " + googleAuthToken,
        }
    }, function(err, data, xhr) {
        if (!err && data && data.error) {
            return callback(data, null, xhr);
        }
        callback(err, data, xhr);
    });
}

function getDemoGCalEvents(callback) {
    Utils.getJSON('data/demoEvents.json', callback);
}

function getGCalEvents(callback) {
    // return getDemoGCalEvents(callback);
    if (!googleAuthToken) {
        return callback('googleAuthToken not set');
    }
    fetchGCalEvents(callback);
}

function fetchWeatherForecast(callback) {
    var url = 'http://api.openweathermap.org/data/2.5/';
    url += 'forecast/daily?id=' + openweathermapCityId;
    url += '&units=metric';
    url += '&appid=' + openweathermapAppId;
    Utils.getJSON(url, callback);
}

function getWeatherForecast(callback) {
    // return Utils.getJSON('data/demoWeatherForecast.json', callback);
    if (!openweathermapAppId) {
        return callback('openweathermapAppId not set');
    } else if (!openweathermapCityId) {
        return callback('openweathermapCityId not set');
    }
    fetchWeatherForecast(callback);
}
