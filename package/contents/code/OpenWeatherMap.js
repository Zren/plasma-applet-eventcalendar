.import "../ui/utils.js" as Utils

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
    Utils.getJSON(url, callback);
}

function fetchDailyWeatherForecast(args, callback) {
    console.log('fetchWeatherForecast');
    if (!args.app_id) return callback('OpenWeatherMap AppId not set');
    if (!args.city_id) return callback('OpenWeatherMap CityId not set');
    
    var url = 'http://api.openweathermap.org/data/2.5/';
    url += 'forecast/daily?id=' + args.city_id;
    url += '&units=' + (args.units || 'metric');
    url += '&appid=' + args.app_id;
    Utils.getJSON(url, callback);
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

function updateDailyWeather(callback) {
    // console.log('fetchDailyWeatherForecast', lastForecastAt, Date.now());
    fetchDailyWeatherForecast({
        app_id: plasmoid.configuration.weather_app_id,
        city_id: plasmoid.configuration.weather_city_id,
        units: plasmoid.configuration.weather_units,
    }, function(err, data, xhr) {
        if (err) return console.log('fetchDailyWeatherForecast.err', err, xhr && xhr.status, data);
        console.log('fetchDailyWeatherForecast.response');
        // console.log('fetchDailyWeatherForecast.response', data);

        callback(err, data);
    });
}

function updateHourlyWeather(callback) {
    // console.log('fetchHourlyWeatherForecast', lastForecastAt, Date.now());
    fetchHourlyWeatherForecast({
        app_id: plasmoid.configuration.weather_app_id,
        city_id: plasmoid.configuration.weather_city_id,
        units: plasmoid.configuration.weather_units,
    }, function(err, data, xhr) {
        if (err) return console.log('fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data);
        console.log('fetchHourlyWeatherForecast.response');
        // console.log('fetchHourlyWeatherForecast.response', data);

        callback(err, data);
    });
}
