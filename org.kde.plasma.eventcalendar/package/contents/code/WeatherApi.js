.import "OpenWeatherMap.js" as OpenWeatherMap
.import "WeatherCanada.js" as WeatherCanada

var weatherService = 'OpenWeatherMap.org';
var dataPointDuration = 3;
// var weatherService = 'weather.gc.ca';
// var dataPointDuration = 1;

function openCityUrl() {
	if (weatherService == 'OpenWeatherMap.org') {
		OpenWeatherMap.openOpenWeatherMapCityUrl(plasmoid.configuration.weather_city_id);
	} else if (weatherService == 'weather.gc.ca') {
		Qt.openUrlExternally(WeatherCanada.testCityUrl);
	}
}

function updateDailyWeather(callback) {
	if (weatherService == 'OpenWeatherMap.org') {
		OpenWeatherMap.updateDailyWeather(callback);
	} else if (weatherService == 'weather.gc.ca') {

	}
}


function updateHourlyWeather(callback) {
	if (weatherService == 'OpenWeatherMap.org') {
		OpenWeatherMap.updateHourlyWeather(callback);
	} else if (weatherService == 'weather.gc.ca') {
		WeatherCanada.updateHourlyWeather(callback);
	}
}
