.import "OpenWeatherMap.js" as OpenWeatherMap
.import "WeatherCanada.js" as WeatherCanada

// var weatherService = 'OpenWeatherMap';
// var dataPointDuration = 3;
// var weatherService = 'WeatherCanada';
// var dataPointDuration = 1;


function getDataPointDuration() {
	var weatherService = plasmoid.configuration.weather_service;
	if (weatherService == 'OpenWeatherMap') {
		return 3;
	} else if (weatherService == 'WeatherCanada') {
		return 1;
	} else {
		return 1;
	}
}

function openCityUrl() {
	var weatherService = plasmoid.configuration.weather_service;
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.openOpenWeatherMapCityUrl(plasmoid.configuration.weather_city_id);
	} else if (weatherService == 'WeatherCanada') {
		Qt.openUrlExternally(WeatherCanada.cityUrl(plasmoid.configuration.weather_canada_city_id));
	}
}

function updateDailyWeather(callback) {
	if (!weatherIsSetup()) {
		return callback('Weather configuration not setup');
	}
	var weatherService = plasmoid.configuration.weather_service;
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateDailyWeather(callback);
	} else if (weatherService == 'WeatherCanada') {

	}
}


function updateHourlyWeather(callback) {
	if (!weatherIsSetup()) {
		return callback('Weather configuration not setup');
	}
	var weatherService = plasmoid.configuration.weather_service;
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateHourlyWeather(callback);
	} else if (weatherService == 'WeatherCanada') {
		WeatherCanada.updateHourlyWeather(callback);
	}
}

function weatherIsSetup() {
	var weatherService = plasmoid.configuration.weather_service;
	if (weatherService == 'OpenWeatherMap') {
		return !!plasmoid.configuration.weather_city_id;
	} else if (weatherService == 'WeatherCanada') {
		return !!plasmoid.configuration.weather_canada_city_id;
	} else {
		return false;
	}
}

var weatherIconBySeverity = [
	// Least Severe
	'weather-clear-night',
	'weather-clear',
	'weather-few-clouds-night',
	'weather-few-clouds',
	'weather-clouds-night',
	'weather-clouds',
	'weather-overcast',
	'weather-fog',
	'weather-overcast',
	'weather-showers-scattered-night',
	'weather-showers-scattered',
	'weather-snow',
	'weather-showers-night',
	'weather-showers',
	'weather-storm-night',
	'weather-storm',
	'weather-severe-alert',
	// Most severe
];

function getMostSevereIcon(weatherIconList) {
	var mostSevereIndex = weatherIconBySeverity.indexOf(weatherIconList[0]);
	for (var i = 1; i < weatherIconList.length; i++) {
		var index = weatherIconBySeverity.indexOf(weatherIconList[i]);
		mostSevereIndex = Math.max(mostSevereIndex, index);
	}
	return weatherIconBySeverity[mostSevereIndex];
}