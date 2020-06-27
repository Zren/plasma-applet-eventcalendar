.import "OpenWeatherMap.js" as OpenWeatherMap
.import "WeatherCanada.js" as WeatherCanada

/* How many hours each data point represents */
function getDataPointDuration() {
	var weatherService = plasmoid.configuration.weather_service
	if (weatherService == 'OpenWeatherMap') {
		return 3
	} else if (weatherService == 'WeatherCanada') {
		return 1
	} else {
		return 1
	}
}

/* Open the city's webpage using Qt.openUrlExternally(url) */
function openCityUrl() {
	var weatherService = plasmoid.configuration.weather_service
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.openOpenWeatherMapCityUrl(plasmoid.configuration.weather_city_id)
	} else if (weatherService == 'WeatherCanada') {
		Qt.openUrlExternally(WeatherCanada.getCityUrl(plasmoid.configuration.weather_canada_city_id))
	}
}

/* Update the weather shown in the agenda. */
/* @returns: callback(err, {
	list: [
		{
			dt: 1474831800, // seconds
			temp: {
				min: 14.5,
				max: 14.5,
				morn: 14.5, // (Optional)
				day: 14.5, // (Optional)
				eve: 14.5, // (Optional)
				night: 14.5, // (Optional)
			},
			iconName: 'weather-clear',
			text: 'Clear', // Word/Short description (the "Weather Text" shown in the agenda)
			description: 'clear sky',  // Sentence (shown in the tooltip)
			notes: 'Morning: 13°\nEvening: 5°', // Tooltip subtext (Optional)
		},
		...
	]
}, xhr)
*/
function updateDailyWeather(callback) {
	if (!weatherIsSetup()) {
		return callback('Weather configuration not setup')
	}
	var weatherService = plasmoid.configuration.weather_service
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateDailyWeather(callback)
	} else if (weatherService == 'WeatherCanada') {
		WeatherCanada.updateDailyWeather(callback)
	}
}

/* Update the meteogram dataset. Will not be called if the meteogram isn't enabled. */
/* @returns: callback(err, {
	list: [
		{
			dt: 1474831800, // seconds
			temp: 14.5,
			iconName: 'weather-clear',
			description: 'clear sky', // Sentence (Tooltip)
			precipitation: 20, // Can represent 20mm or 20%
		},
		...
	]
}, xhr)
*/
function updateHourlyWeather(callback) {
	if (!weatherIsSetup()) {
		return callback('Weather configuration not setup')
	}
	var weatherService = plasmoid.configuration.weather_service
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateHourlyWeather(callback)
	} else if (weatherService == 'WeatherCanada') {
		WeatherCanada.updateHourlyWeather(callback)
	}
}

/* Return true if all configuration has been setup. */
function weatherIsSetup() {
	var weatherService = plasmoid.configuration.weather_service
	if (weatherService == 'OpenWeatherMap') {
		return !!plasmoid.configuration.weather_city_id
	} else if (weatherService == 'WeatherCanada') {
		return !!plasmoid.configuration.weather_canada_city_id
	} else {
		return false
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
	'weather-snow-scattered-night',
	'weather-snow-scattered-day',
	'weather-snow',
	'weather-snow-rain-night',
	'weather-snow-rain',
	'weather-showers-night',
	'weather-showers',
	'weather-storm-night',
	'weather-storm',
	'weather-severe-alert',
	// Most severe
]

function getMostSevereIcon(weatherIconList) {
	var mostSevereIndex = weatherIconBySeverity.indexOf(weatherIconList[0])
	for (var i = 1; i < weatherIconList.length; i++) {
		var index = weatherIconBySeverity.indexOf(weatherIconList[i])
		mostSevereIndex = Math.max(mostSevereIndex, index)
	}
	if (mostSevereIndex === -1) {
		return weatherIconList[0]
	}
	return weatherIconBySeverity[mostSevereIndex]
}
