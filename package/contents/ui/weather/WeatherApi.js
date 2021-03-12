.pragma library

.import "OpenWeatherMap.js" as OpenWeatherMap
.import "WeatherCanada.js" as WeatherCanada

/* How many hours each data point represents */
function getDataPointDuration(config) {
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		return 3
	} else if (weatherService == 'WeatherCanada') {
		return 1
	} else {
		return 1
	}
}

/* Precipitation units ('mm' or '%') */
function getRainUnits(config) {
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		return 'mm'
	} else if (weatherService == 'WeatherCanada') {
		return '%'
	} else {
		return 'mm'
	}
}

/* Open the city's webpage using Qt.openUrlExternally(url) */
function openCityUrl(config) {
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.openOpenWeatherMapCityUrl(config.openWeatherMapCityId)
	} else if (weatherService == 'WeatherCanada') {
		Qt.openUrlExternally(WeatherCanada.getCityUrl(config.weatherCanadaCityId))
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
function updateDailyWeather(config, callback) {
	if (!weatherIsSetup(config)) {
		return callback('Weather configuration not setup')
	}
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateDailyWeather(config, callback)
	} else if (weatherService == 'WeatherCanada') {
		WeatherCanada.updateDailyWeather(config, callback)
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
function updateHourlyWeather(config, callback) {
	if (!weatherIsSetup(config)) {
		return callback('Weather configuration not setup')
	}
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		OpenWeatherMap.updateHourlyWeather(config, callback)
	} else if (weatherService == 'WeatherCanada') {
		WeatherCanada.updateHourlyWeather(config, callback)
	}
}

/* Return true if all configuration has been setup. */
function weatherIsSetup(config) {
	var weatherService = config.weatherService
	if (weatherService == 'OpenWeatherMap') {
		return OpenWeatherMap.weatherIsSetup(config)
	} else if (weatherService == 'WeatherCanada') {
		return WeatherCanada.weatherIsSetup(config)
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
