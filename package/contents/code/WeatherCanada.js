.pragma library

.import "../ui/lib/Requests.js" as Requests

/* Note, dd.weatheroffice.ec.gc.ca does exist, but it doesn't contain the hourly forecast,
nor does the city id match the one used on the website, so it's easier to just parse the html.

http://dd.weatheroffice.ec.gc.ca/citypage_weather/docs/README_citypage_weather.txt
http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/siteList.xml
http://dd.weatheroffice.ec.gc.ca/citypage_weather/xml/ON/s0000001_e.xml
*/

function weatherIsSetup(config) {
	if (!!config.weatherCanadaCityId) {
		var matches = /[a-z]{2}-\d+/.exec(config.weatherCanadaCityId)
		return !!matches
	} else {
		return false
	}
}

// http://dd.weather.gc.ca/citypage_weather/docs/current_conditions_icon_code_descriptions_e.csv
// http://dd.weather.gc.ca/citypage_weather/docs/forecast_conditions_icon_code_descriptions_e.csv
var weatherIconMap = {
	'00': 'weather-clear', // Sunny
	'01': 'weather-clear', // Mainly sunny
	'02': 'weather-few-clouds', // Partly Cloudy
		// A mix of sun and cloud
	'03': 'weather-clouds', // Mainly cloudy
	'04': 'weather-few-clouds', // Increasing cloudiness
	'05': 'weather-few-clouds', // Clearing
	'06': 'weather-showers-scattered', // Chance of showers
	'07': 'weather-snow-rain',
		// Chance of flurries or rain showers [Sun]
		// Rain showers or flurries [Sun]
	'08': 'weather-snow-scattered-day', // Chance of flurries [Sun]
	'09': 'weather-storm', // Chance of thunderstorms. Risk of severe thunderstorms
		// Chance of thunderstorms
	'10': 'weather-clouds', // Cloudy
		// Overcast
	'11': 'weather-showers',
		// Squalls
		// Light Precipitation
		// Heavy Precipitation
	'12': 'weather-showers', // Showers
	'13': 'weather-showers', // Rain
	'14': 'weather-freezing-rain', // Freezing Rain
	'15': 'weather-snow-rain', // Chance of flurries or rain showers [Cloud]
	'16': 'weather-snow',
		// Chance of flurries [Cloud]
		// Flurries [Cloud]
	'17': 'weather-snow', // Snow [Cloud]
	'18': 'weather-snow', // Blizzard
	'19': 'weather-storm', // Chance of showers. Risk of thundershowers
	'20': 'question', // [? Same icon as 24 (fog)]
	'21': 'question', // [? Same icon as 24 (fog)]
	'22': 'weather-few-clouds', // A mix of sun and cloud
	'23': 'weather-fog', // Haze
	'24': 'weather-fog',
		// Fog
		// Fog Patches
		// Ice fog
	'25': 'weather-snow', // Drifting Snow
	'26': 'weather-snow', // Ice Crystals
	'27': 'weather-hail', // Hail
	'28': 'weather-freezing-rain',
		// Drizzle
		// Freezing drizzle

	'29': 'question', // Not available

	'30': 'weather-clear-night', // Clear
	'31': 'weather-few-clouds-night', // A few clouds
	'32': 'weather-few-clouds-night', // Partly cloudy
	'33': 'weather-clouds-night', // Mainly cloudy
	'34': 'weather-few-clouds-night', // Increasing cloudiness
	'35': 'weather-few-clouds-night', // Clearing [Moon]
	'36': 'weather-showers-scattered-night', // Chance of showers
	'37': 'weather-snow-rain-night', // Chance of flurries or rain showers [Moon]
	'38': 'weather-snow', // Chance of flurries [Moon]
	'39': 'weather-storm-night', // Chance of showers. Risk of thunderstorms

	'40': 'weather-snow', // Blowing Snow
	'41': 'wi-tornado', // Funnel Cloud
	'42': 'wi-tornado', // Tornado
	'43': 'wi-windy', // Windy
	'44': 'wi-smoke', // Smoke
	'45': 'wi-sandstorm', // Sandstorm
	'46': 'weather-storm', // Thunderstorm with Hail
	'47': 'weather-storm', // Thunderstorm with Dust Storm
	'48': 'wi-tornado', // Waterspout
}


var weatherIconToTextMap = {}
/* Don't burden translators with these for now.
var weatherIconToTextMap = {
	'weather-clear': i18n("Clear"),
	'weather-clear-night': i18n("Clear"),
	'weather-clouds': i18n("Cloudy"),
	'weather-clouds-night': i18n("Cloudy"),
	'weather-few-clouds': i18n("Cloudy"),
	'weather-few-clouds-night': i18n("Cloudy"),
	'weather-fog': i18n("Fog"),
	'weather-freezing-rain': i18n("Freezing Rain"),
	'weather-hail': i18n("Hail"),
	'weather-overcast': i18n("Overcast"),
	'weather-showers': i18n("Rain"),
	'weather-showers-night': i18n("Rain"),
	'weather-showers-scattered': i18n("Showers"),
	'weather-showers-scattered-night': i18n("Showers"),
	'weather-snow': i18n("Snow"),
	'weather-snow-rain': i18n("Snow/Rain"),
	'weather-snow-rain-night': i18n("Snow/Rain"),
	'weather-snow-scattered-day': i18n("Snow"),
	'weather-snow-scattered-night': i18n("Snow"),
	'weather-storm': i18n("Storm"),
	'weather-storm-night': i18n("Storm"),
	'wi-dust': i18n("Dust"),
	'wi-sandstorm': i18n("Sandstorm"),
	'wi-smoke': i18n("Smoke"),
	'wi-tornado': i18n("Tornado"),
	'wi-windy': i18n("Windy"),
}
*/

function getInner(html, a, b) {
	var start = html.indexOf(a)
	if (start == -1) return ''
	start += a.length
	var end = html.indexOf(b, start)
	if (end == -1) return ''
	return html.substr(start, end-start)
}

function loopInner(html, a, b, callback) {
	var cursor = 0
	for (var i = 0; i < 1000; i++) { // Hard limit of 1000 iterations
		var start = html.indexOf(a, cursor)
		if (start == -1) {
			break
		}
		start += a.length
		// console.log('loop', i, 'with', start, cursor)
		var end = html.indexOf(b, start)
		var innerHtml = html.substr(start, end-start)
		// console.log(i, start, end, innerHtml)
		callback(innerHtml, i)
		cursor = end + b.length
		// console.log('cursor', cursor)
	}
}

function parseFutureDate(day, month) {
	// QML doesn't parse: new Date('25 Sep')
	// So we need to specify the year
	// Hardcode Jan == next year when in December
	var date = new Date()
	if (month == 'Jan' && date.getMonth() == 11) { // == December, getMonth() returns 0-11
		return new Date(day + ' ' + month + ' ' + (date.getFullYear() + 1))
	} else {
		return new Date(day + ' ' + month + ' ' + date.getFullYear())
	}
}


function parseDailyHtml(html) {
	// var tableHtml = getInner(html, '<table class="table mrgn-bttm-md mrgn-tp-md textforecast hidden-xs">', '</table>')
	// console.log('tableHtml', tableHtml)

	var weatherData = {
		list: []
	}

	

	// Daily forcast is a 7x4 table
	// <th> Today | Mon 21 Nov | Tue 22 Nov | ...
	// <td> Icon -1*C 60% Desc | ... (high temp)
	// <th> Tonight | Night | Night | ...
	// <td> Icon -6*C 60% Desc | ... (low temp)
	var forecastHtml = getInner(html, '<table class="table table-condensed mrgn-bttm-0 wxo-iconfore hidden-xs">', '</table>')

	var todayHtml = getInner(html, '<span class="small visible-print-inline-block pull-right">Issued: ', '</span>') // 3:30 PM EST Sunday 20 November 2016
	// Skip Time by looking for T which doesn't exist in the hours/minutes/AM/PM,
	// but exists at the end of the time zone: PST, MST, CST, EST, AST, NST
	var todayStr = todayHtml.substr(todayHtml.indexOf('T') + 'T '.length)
	// Skip day name (Sunday, Monday, ...) since Qt doesn't like it.
	todayStr = todayStr.substr(todayStr.indexOf(' ') + ' '.length)
	var today = new Date(todayStr)
	// console.log('today', todayHtml, todayStr, today)

	var weeklyData = [] // 7 day forecast
	for (var i = 0; i < 7; i++) {
		weeklyData.push({
			dt: 0,
			temp: {
				max: 0,
				min: 0,
			},
			iconName: '',
			text: '',
			description: '',
			notes: '',
		})
	}
	var evening = false // Did we skip Today's daytime?

	// Loop the two rows of 7 <td>.
	// console.log('forecastHtml', forecastHtml)
	loopInner(forecastHtml, '<td', '</td>', function(innerHtml, innerIndex) {
		var date = new Date(today)
		var dateIndex = innerIndex % 7 // 7 columns represent 7 days
		date.setDate(date.getDate() + dateIndex)
		// console.log(innerIndex, date)

		var dateData = weeklyData[dateIndex]

		dateData.dt = date.valueOf() / 1000

		if (innerHtml.indexOf('class="greybkgrd"') >= 0) {
			// Today (daytime) is over, we'll use nighttime data
			evening = true
		} else {
			if (innerIndex < 7 || (evening && innerIndex == 7)) {
				// Use daytime weather
				var imageId = getInner(innerHtml, 'src="/weathericons/', '.gif"')
				dateData.iconName = weatherIconMap[imageId]
				dateData.description = getInner(innerHtml, '.gif" alt="', '"')
				dateData.text = weatherIconToTextMap[dateData.iconName] || dateData.description
			}

			// Temps
			// TODO: check plasmoid.configuration.weatherUnits == 'imperial' to use farenheit.
			// TODO: check for 'kelvin' and subtract 273 from metric
			// TODO: Give a shit
			if (innerIndex < 7) {
				// high
				var high = getInner(innerHtml, 'wxo-metric-hide" title="max">', '&deg;<abbr title="Celsius">C</abbr>')
				high = parseInt(high, 10)
				dateData.temp.max = high
			} else {
				// low
				var low = getInner(innerHtml, 'wxo-metric-hide" title="min">', '&deg;<abbr title="Celsius">C</abbr>')
				low = parseInt(low, 10)
				dateData.temp.min = low

				if (evening && dateIndex == 8) {
					// For now, use the low as the current temperature for "Tonight".
					// TODO: look at current conditions.
					dateData.temp.max = low
				}
			}
		}

		// var notesHtml = getInner(tableHtml, '\u00A0' + day + '\u00A0<abbr title="', '<strong>')
		// console.log('notesHtml', notesHtml)
		// if (!notesHtml) { // Last item
		// 	notesHtml = getInner(tableHtml, '\u00A0' + day + '\u00A0<abbr title="', '</tbody>')
		// 	console.log('notesHtml', notesHtml)
		// }
		// var dayNotes = getInner(notesHtml, '</td>\n              <td>', '</td>')
		// console.log('dayNotes', dayNotes)
		// if (notesHtml.indexOf('night">Tonight</strong>') >= 0) {
		// 	notes = i18n("<b>Tonight:</b> %1", dayNotes)
		// } else {
		// 	var nightNotes = getInner(notesHtml, 'night"> Night\n</td>\n              <td>', '</td>')
		// 	// console.log('nightNotes', nightNotes)
		// 	if (nightNotes) {
		// 		notes = i18n("%1<br><b>Night:</b> %2", dayNotes, nightNotes)
		// 	} else { // Last item (w/ Tonight as first item)
		// 		notes = dayNotes
		// 	}
		// }
		
		// notes = dayNotes + '<br>' + nightNotes
		
		// console.log(dateIndex, JSON.stringify(dateData, null, "\t"))
	})

	weatherData.list = weeklyData

	return weatherData
}



function parseHourlyHtml(html) {
	html = getInner(html, '<tbody>', '</tbody>')
	return parseHourlyTbody(html)
}
function parseHourlyTbody(html) {
	// Iterate all <tr>
	var cursor = 0
	var dateStr
	var weatherData = {
		list: []
	}
	for (var i = 0; i < 1000; i++) { // Hard limit of 1000 iterations
		var start = html.indexOf('<tr>', cursor)
		if (start == -1) {
			break
		}
		start += '<tr>'.length
		var end = html.indexOf('</tr>', cursor)
		var trHtml = html.substr(start, end-start)

		if (trHtml.indexOf('<th ') >= 0) {
			// Date heading
			dateStr = parseHourlyDate(trHtml)
			// console.log(dateStr)
		} else {
			// Hourly forecast
			var timeStr = parseHourlyTime(trHtml)
			var temp = parseHourlyTemp(trHtml)
			var conditions = parseHourlyConditions(trHtml)
			var dt = Math.floor(new Date(dateStr + ' ' + timeStr).getTime() / 1000)
			var precipitation = parseHourlyPrecipitation(trHtml)
			// console.log(dt, timeStr, conditions.icon, conditions.id, conditions.description, precipitation)

			weatherData.list.push({
				dt: dt,
				temp: temp,
				iconName: conditions.icon,
				description: conditions.description,
				precipitation: precipitation,
			})
		}

		cursor = end + '</tr>'.length
	}
	return weatherData
}
function parseHourlyDate(trHtml) {
	return getInner(trHtml, '>', '</')
}
function parseHourlyTime(trHtml) {
	return getInner(trHtml, '<td headers="header1" class="text-center">', '</td>')
}
function parseHourlyTemp(trHtml) {
	var str = getInner(trHtml, '<td headers="header2" class="text-center">', '</td>')
	return parseInt(str, 10)
}
function parseHourlyConditions(trHtml) {
	var td = getInner(trHtml, '<td headers="header3" class="media">', '</td>')
	var imageId = getInner(td, 'src="/weathericons/small/', '.png"')
	var text = getInner(td, '<p>', '</p>')

	return {
		id: imageId,
		icon: weatherIconMap[imageId],
		description: text,
	}
}
function parseHourlyPrecipitation(trHtml) {
	var text = getInner(trHtml, '<td headers="header4" class="text-center">', '</td>')
	// This page doesn't list the exact values unfortunately,
	// so we'll go with the minimum the threshold represents.
	if (text == 'Low') { // 1 - 40%
		return 20 // %
	} else if (text == 'Medium') { // 60 - 70%
		return 60 // %
	} else if (text == 'High') { // 70% +
		return 70 // %
	} else { // == 'Nil'
		return 0
	}
}



function getCityUrl(cityId) {
	return 'https://weather.gc.ca/city/pages/' + cityId + '_metric_e.html'
}

function updateDailyWeather(config, callback) {
	var url = getCityUrl(config.weatherCanadaCityId)
	Requests.request(url, function(err, data, xhr) {
		if (err) return console.error('WeatherCanada.fetchDailyWeatherForecast.err', err, xhr && xhr.status, data)
		// console.debug('WeatherCanada.fetchDailyWeatherForecast.response')
		
		var weatherData = parseDailyHtml(data)
		// console.log(JSON.stringify(weatherData, null, '\t'))
		callback(err, weatherData, xhr)
	})
}

function getCityHourlyUrl(cityId) {
	return 'https://weather.gc.ca/forecast/hourly/' + cityId + '_metric_e.html'
}

function updateHourlyWeather(config, callback) {
	var url = getCityHourlyUrl(config.weatherCanadaCityId)
	Requests.request(url, function(err, data, xhr) {
		if (err) return console.error('WeatherCanada.fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data)
		// console.debug('WeatherCanada.fetchHourlyWeatherForecast.response')
		
		var weatherData = parseHourlyHtml(data)
		// console.log(JSON.stringify(weatherData, null, '\t'))
		callback(err, weatherData, xhr)
	})
}


function parseCityList(html) {
	var lines = html.split('\n')
	var cityList = []

	for (var i = 0; i < lines.length; i++) {
		var line = lines[i]
		if (line.indexOf('<li><a href="') !== 0) {
			continue // <ul>/</ul>/...
		}
		var cityId = getInner(line, '<li><a href="/city/pages/', '_metric_e.html')
		var cityName = getInner(line, '_metric_e.html">', '</a></li>')
		cityList.push({
			id: cityId,
			name: cityName,
		})
	}
	return cityList
}
function parseProvincePage(html) {
	html = getInner(html, '[Provincial Summary]</a>&nbsp;</p>\n<div class="well"><div class="row">', '</div></div>')
	return parseCityList(html)
}
