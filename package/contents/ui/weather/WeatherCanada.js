.pragma library

.import "../lib/Requests.js" as Requests

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
		if (end == -1) {
			break
		}
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
	var weatherData = {
		list: []
	}

	// The current conditions section contains the current temp.
	// We'll need this in the evening since we no longer have the daytime high.
	var currentHtml = getInner(html, '<h2>Current Conditions<span', '</details>')
	if (!currentHtml) {
		throw new Error('Error parsing currentHtml')
	}
	// console.debug('currentHtml', currentHtml)

	var currentTemp = getInner(currentHtml, '<span class="wxo-metric-hide">', '°<abbr title="Celsius">C</abbr>')
	if (!currentTemp) {
		throw new Error('Error parsing currentTemp')
	}
	currentTemp = parseInt(currentTemp, 10)


	// The forecast "table" can be found using the unique 'details.wxo-fcst' selector.
	// Note that there is two elements matching this selector. We want the desktop view.
	//     Desktop view: <details class="panel panel-default wxo-fcst" open="open">
	//     Mobile view: <details class="panel panel-default wxo-fcst mrgn-bttm-md mrgn-tp-md" open="open">
	var forecastHtml = getInner(html, '<details class="panel panel-default wxo-fcst" open="open">', '</details>')
	if (!forecastHtml) {
		throw new Error('Error parsing forecastHtml')
	}
	// console.debug('forecastHtml', forecastHtml)


	// Daily forcast is a 7x4 table using divs + css instead of a table.
	// <details class="panel panel-default wxo-fcst" open="open">
	//   <summary>...</summary>
	//   <ul>...</ul>
	//   <div class="div-table">
	//     <div class="div-column">...</div>

	// Inside each column is 4 rows. For the first column representing today/tonight, there is
	// an anchor link with the hourly forecast wrapping the row div. We can easily ignore the <a> though.
	// <div class="div-column">
	// 	<div class="div-row div-row1 div-row-head" style="height: 58px;">
	// 		<a href="/forecast/hourly/on-143_metric_e.html">
	// 			<strong title="Friday">Fri</strong><br>
	// 			12 <abbr title="March">Mar</abbr></br>
	// 		</a>
	// 	</div>
	// 	<a class="linkdate" href="/forecast/hourly/on-143_metric_e.html">
	// 		<div class="div-row div-row2 div-row-data" style="height: 166px;">
	// 			<img alt="Mainly sunny" class="center-block" height="51" src="/weathericons/01.gif" width="60">
	// 				<p class="mrgn-bttm-0">
	// 					<span class="high wxo-metric-hide" title="max">10°<abbr title="Celsius">C</abbr></span>
	// 					<span class="high wxo-imperial-hide wxo-city-hidden" title="max">50°<abbr title="Fahrenheit">F</abbr></span>
	// 				</p>
	// 				<p class="mrgn-bttm-0 pop text-center"></p>
	// 				<p class="mrgn-bttm-0">Mainly sunny</p>
	// 			</img>
	// 		</div>
	// 	</a>
	// 	<div class="div-row div-row3 div-row-head" style="height: 35px;">Tonight</div>
	// 	<div class="div-row div-row4 div-row-data" style="height: 166px;">
	// 		<img alt="A few clouds" class="center-block" height="51" src="/weathericons/31.gif" width="60">
	// 			<p class="mrgn-bttm-0">
	// 				<span class="low wxo-metric-hide" title="min">-5°<abbr title="Celsius">C</abbr></span>
	// 				<span class="low wxo-imperial-hide wxo-city-hidden" title="min">23°<abbr title="Fahrenheit">F</abbr></span>
	// 			</p>
	// 			<p class="mrgn-bttm-0 pop text-center"></p>
	// 			<p class="mrgn-bttm-0">A few clouds</p>
	// 		</img>
	// 	</div>
	// </div>


	// During night, today's daytime cell is blank.
	//   <div class="div-row div-row1 div-row-head greybkgrd"> </div>
	//   <div class="div-row div-row2 div-row-data greybkgrd"> </div>
	// During daytime, the nighttime data for the last day in the forecast is blank.
	//   <div class="div-row div-row3 div-row-head greybkgrd"> </div>
	//   <div class="div-row div-row4 div-row-data greybkgrd"> </div>
	var evening = forecastHtml.indexOf('class="div-row div-row1 div-row-head greybkgrd"') >= 0
	// console.debug('evening', evening)


	// Today's date
	var pageModifiedStr = getInner(html, '<meta name="dcterms.modified" title="W3CDTF" content="', '" />') // 2021-03-12
	if (!pageModifiedStr) {
		throw new Error('Error parsing pageModifiedStr')
	}
	// We need to append the time string (without a timezone) to get midnight of the current timezone.
	var today = new Date(pageModifiedStr + 'T00:00:00')
	if (isNaN(today)) {
		throw new Error('Error parsing todays date')
	}
	// console.debug('today', today, 'pageModifiedStr', pageModifiedStr)

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

	// Daily forecast loop
	// While <div class="div-column"> is pretty unique, the columns just end with </div> which isn't.
	// So we get the start and end of the table first, then split it by <div class="div-column">.
	var tableHtml = getInner(forecastHtml, '<div class="div-table">', '<section><details open="open" class="wxo-detailedfore">')
	tableHtml = tableHtml.trim() // Strip \n before first "div-column".
	// console.debug('tableHtml', tableHtml)

	// Since there's a <div class="div-column"> at the start, we need to remove the leading empty string.
	var divColumns = tableHtml.split('<div class="div-column">')
	if (divColumns.length >= 1 && divColumns[0] == '') {
		divColumns.shift()
	}
	// console.debug(JSON.stringify(divColumns, null, '\t'))

	divColumns.forEach(function(innerHtml, dateIndex) {
		var date = new Date(today)
		date.setDate(date.getDate() + dateIndex)
		// console.debug(dateIndex, date)

		var dateData = weeklyData[dateIndex]

		dateData.dt = date.valueOf() / 1000

		// Forecast Icon + Text
		var imageId = getInner(innerHtml, 'src="/weathericons/', '.gif"')
		if (!imageId) {
			throw new Error('Error parsing weather icon')
		}

		dateData.iconName = weatherIconMap[imageId]
		if (!dateData.iconName) {
			console.log('[eventcalendar] WeatherCanada icon not mapped (/weathericons/' + imageId + '.gif)')
		}
		dateData.description = getInner(innerHtml, '.gif" alt="', '"')
		if (!dateData.description) {
			console.log('[eventcalendar] WeatherCanada icon has no description (/weathericons/' + imageId + '.gif)')
		}
		dateData.text = weatherIconToTextMap[dateData.iconName] || dateData.description


		// Temps
		var high = getInner(innerHtml, '<span class="high wxo-metric-hide" title="max">', '°<abbr title="Celsius">C</abbr>')
		high = parseInt(high, 10)

		var low = getInner(innerHtml, '<span class="low wxo-metric-hide" title="min">', '°<abbr title="Celsius">C</abbr>')
		low = parseInt(low, 10)

		if (isNaN(high) && isNaN(low)) {
			throw new Error('Error parsing daily temp')
		} else if (dateIndex == 0 && isNaN(high) && !isNaN(low)) {
			// We're currently in the evening so there won't be a daytime high.
			// So we use the current temp as the high.
			dateData.temp.max = currentTemp
			dateData.temp.min = low
		} else if (dateIndex == 6 && isNaN(low) && !isNaN(high)) {
			// During the daytime, our maximum weekly forecast runs out of data before the 7th evening.
			// So there won't be a night low for the last day.
			// Well send a NaN to display a ?
			dateData.temp.max = high
			dateData.temp.min = NaN
		} else {
			dateData.temp.max = high
			dateData.temp.min = low
		}

		if (isNaN(high) && isNaN(low)) {
			throw new Error('Error parsing daily temp')
		}

		// console.debug(dateIndex, JSON.stringify(dateData, null, "\t"))
	})

	weatherData.list = weeklyData

	return weatherData
}



function parseHourlyHtml(html) {
	var tableHtml = getInner(html, '<tbody>', '</tbody>')
	if (!tableHtml) {
		throw new Error('Error parsing hourly table')
	}
	return parseHourlyTbody(tableHtml)
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
		if (end == -1) {
			throw new Error('Error parsing hourly row. Closing </tr> not found.')
		}
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
	var str = getInner(trHtml, '>', '</')
	if (!str) {
		throw new Error('Error parsing hourly date.')
	}
	return str
}
function parseHourlyTime(trHtml) {
	var str = getInner(trHtml, '<td headers="header1" class="text-center">', '</td>')
	if (!str) {
		throw new Error('Error parsing hourly time.')
	}
	return str
}
function parseHourlyTemp(trHtml) {
	var str = getInner(trHtml, '<td headers="header2" class="text-center">', '</td>')
	if (!str) {
		throw new Error('Error parsing hourly temp.')
	}
	return parseInt(str, 10)
}
function parseHourlyConditions(trHtml) {
	var td = getInner(trHtml, '<td headers="header3" class="media">', '</td>')
	if (!td) {
		throw new Error('Error parsing hourly conditions td.')
	}
	var imageId = getInner(td, 'src="/weathericons/small/', '.png"')
	if (!imageId) {
		throw new Error('Error parsing hourly imageId.')
	}
	var text = getInner(td, '<p>', '</p>')
	if (!text) {
		throw new Error('Error parsing hourly text.')
	}

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

function handleError(funcName, callback, err, data, xhr) {
	console.error('[eventcalendar]', funcName + '.err', err, xhr && xhr.status, data)
	return callback(err, data, xhr)
}

function updateDailyWeather(config, callback) {
	// console.debug('WeatherCanada.fetchDailyWeatherForecast')
	var url = getCityUrl(config.weatherCanadaCityId)
	Requests.request(url, function(err, data, xhr) {
		if (err) return handleError('WeatherCanada.fetchDailyWeatherForecast', callback, err, data, xhr)
		// console.debug('WeatherCanada.fetchDailyWeatherForecast.response')
		// console.debug('WeatherCanada.fetchDailyWeatherForecast.response', data)

		try {
			var weatherData = parseDailyHtml(data)
		} catch (e) {
			// Don't log data as the HTML is longer than the default scrollback.
			return handleError('WeatherCanada.parseDailyHtml', callback, e.message, '', xhr)
		}

		// console.debug(JSON.stringify(weatherData, null, '\t'))
		callback(null, weatherData, xhr)
	})
}

function getCityHourlyUrl(cityId) {
	return 'https://weather.gc.ca/forecast/hourly/' + cityId + '_metric_e.html'
}

function updateHourlyWeather(config, callback) {
	// console.debug('WeatherCanada.fetchHourlyWeatherForecast')
	var url = getCityHourlyUrl(config.weatherCanadaCityId)
	Requests.request(url, function(err, data, xhr) {
		if (err) return handleError('WeatherCanada.fetchHourlyWeatherForecast', callback, err, data, xhr)
		// console.debug('WeatherCanada.fetchHourlyWeatherForecast.response')
		// console.debug('WeatherCanada.fetchHourlyWeatherForecast.response', data)

		try {
			var weatherData = parseHourlyHtml(data)
		} catch (e) {
			// Don't log data as the HTML is longer than the default scrollback.
			return handleError('WeatherCanada.parseHourlyHtml', callback, e.message, '', xhr)
		}
		// console.debug(JSON.stringify(weatherData, null, '\t'))
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
	html = getInner(html, '\n<div class="well"><div class="row">', '</div></div>')
	return parseCityList(html)
}
