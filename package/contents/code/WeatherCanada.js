.import "../ui/utils.js" as Utils

var weatherIconMap = {
    '00': 'weather-clear', // Sunny
    '01': 'weather-clear', // Mainly sunny
    '02': 'weather-few-clouds', // Partly Cloudy
        // A mix of sun and cloud
    '03': 'weather-clouds', // Mainly cloudy
    '': 'weather-overcast',
    '06': 'weather-showers-scattered', // Chance of showers
    '09': 'weather-storm', // Chance of thunderstorms. Risk of severe thunderstorms
        // Chance of thunderstorms
    '10': 'weather-clouds', // Cloudy
        // Overcast
    '12': 'weather-showers', // Showers
        // Rain
        // Chance of showers
    '15': '', // Chance of flurries or rain showers
    '16': '', // Chance of flurries

    '19': 'weather-storm', // Chance of showers. Risk of thundershowers
    '': 'weather-snow',
    '': 'weather-fog',

    '30': 'weather-clear-night', // Clear
    '31': 'weather-few-clouds-night', // A few clouds
    '32': 'weather-few-clouds-night', // Partly cloudy
    '33': 'weather-clouds-night', // Mainly cloudy
    '34': 'weather-few-clouds-night', // Increasing cloudiness
    '': 'weather-overcast',
    '36': 'weather-showers-scattered-night', // Chance of showers
    '': 'weather-showers-night',
    '39': 'weather-storm-night', // Chance of showers. Risk of thunderstorms
    '': 'weather-snow',
    '': 'weather-fog',
};

var weatherIconToTextMap = {
    'weather-clear': i18n("Clear"),
    'weather-few-clouds': i18n("Cloudy"),
    'weather-clouds': i18n("Cloudy"),
    'weather-overcast': i18n("Overcast"),
    'weather-showers-scattered': i18n("Showers"),
    'weather-showers': i18n("Rain"),
    'weather-storm': i18n("Storm"),
    'weather-snow': i18n("Snow"),
    'weather-fog': i18n("Fog"),

    'weather-clear-night': i18n("Clear"),
    'weather-few-clouds-night': i18n("Cloudy"),
    'weather-clouds-night': i18n("Cloudy"),
    'weather-overcast': i18n("Overcast"),
    'weather-showers-scattered-night': i18n("Showers"),
    'weather-showers-night': i18n("Rain"),
    'weather-storm-night': i18n("Storm"),
    'weather-snow': i18n("Snow"),
    'weather-fog': i18n("Fog"),
}

function getInner(html, a, b) {
    var start = html.indexOf(a);
    if (start == -1) return '';
    start += a.length;
    var end = html.indexOf(b, start);
    if (end == -1) return '';
    return html.substr(start, end-start);
}

function loopInner(html, a, b, callback) {
    var cursor = 0;
    for (var i = 0; i < 1000; i++) { // Hard limit of 1000 iterations
        var start = html.indexOf(a, cursor);
        if (start == -1) {
            break;
        }
        start += a.length;
        var end = html.indexOf(b, cursor);
        var innerHtml = html.substr(start, end-start);
        callback(innerHtml, i);
        cursor = end + b.length;
    }
}

function parseFutureDate(day, month) {
    // QML doesn't parse: new Date('25 Sep')
    // So we need to specify the year
    // Hardcode Jan == next year when in December
    var date = new Date();
    if (month == 'Jan' && date.getMonth() == 11) { // == December, getMonth() returns 0-11
        return new Date(day + ' ' + month + ' ' + (date.getFullYear() + 1))
    } else {
        return new Date(day + ' ' + month + ' ' + date.getFullYear())
    }
}


function parseDailyHtml(html) {
    var tableHtml = getInner(html, '<table class="table mrgn-bttm-md mrgn-tp-md textforecast hidden-xs">', '</table>');
    // console.log('tableHtml', tableHtml)
    
    var forecastHtml = getInner(html, '<h3 class="wb-inv">Graphic forecast</h3>', '<h3 class="wb-inv">Detailed forecast</h3>');

/*
            <div class="fcst brdr-rght brdr-bttm text-center">
              <p class="brdr-bttm">
                <a href="/forecast/hourly/on-5_metric_e.html">
                  <strong title="Sunday night">Sun</strong>
                  <br>25 <abbr title="September">Sep</abbr>
                </a>
              </p>
              <p class="mrgn-bttm-0"><img width="60" height="51" src="/weathericons/34.gif" alt="Increasing cloudiness" class="center-block" title="Increasing cloudiness"></p>
              <p class="pop text-center mrgn-bttm-0" title="Chance of Precipitation">
                <small> </small>
              </p>
              <p class="mrgn-bttm-0"><span class="high" title="high"> </span></p>
              <p class="low mrgn-bttm-0"> </p>
            </div>
            <div class="fcst brdr-rght brdr-bttm text-center">
              <p class="brdr-bttm">
                <strong title="Monday">Mon</strong>
                <br>26 <abbr title="September">Sep</abbr>
              </p>
              <p class="mrgn-bttm-0"><img width="60" height="51" src="/weathericons/12.gif" alt="Showers" class="center-block" title="Showers"></p>
              <p class="pop text-center mrgn-bttm-0" title="Chance of Precipitation">
                <small> </small>
              </p>
              <p class="mrgn-bttm-0"><span class="high wxo-metric-hide" title="high">18&deg;<abbr title="Celsius">C</abbr>
                </span><span class="high wxo-imperial-hide wxo-city-hidden" title="high">64&deg;<abbr title="Fahrenheit">F</abbr>
                </span>
              </p>
              <p class="fcstlow mrgn-bttm-0"><span class="low wxo-metric-hide" title="low">10&deg;<abbr title="Celsius">C</abbr>
                </span><span class="low wxo-imperial-hide wxo-city-hidden" title="low">50&deg;<abbr title="Fahrenheit">F</abbr>
                </span>
              </p>
            </div>
*/
    var weatherData = {
        list: []
    };

    loopInner(forecastHtml, '<div class="fcst brdr-rght brdr-bttm text-center">', '</div>', function(innerHtml, innerIndex) {
        var day = getInner(innerHtml, '<br>', '\u00A0<abbr '); // \u00A0 = No Break Space
        var month = getInner(innerHtml, 'abbr title="', '/abbr>')
        month = getInner(month, '">', '<')
        var date = parseFutureDate(day, month)
        var dt = date.valueOf() / 1000

        var imageId = getInner(innerHtml, 'src="/weathericons/', '.gif"');
        var iconName = weatherIconMap[imageId];
        var description = getInner(innerHtml, '.gif" alt="', '"');

        // console.log(day, month, date, date.valueOf())
        // console.log(dt, imageId, iconName, description)
        
        var high = 0;
        var low = 0;
        if (innerIndex == 0) {
            // Today
            // low and high aren't shown at the end of the day
            // so use the current temp
        } else {
            // TODO: check plasmoid.configuration.weather_units == 'imperial' to use farenheit.
            // TODO: check for 'kelvin' and subtract 273 from metric
            // TODO: Give a shit
            var high = getInner(innerHtml, 'wxo-metric-hide" title="high">', '&deg;<abbr title="Celsius">C</abbr>');
            var low = getInner(innerHtml, 'wxo-metric-hide" title="low">', '&deg;<abbr title="Celsius">C</abbr>');
        }
        high = parseInt(high, 10);
        low = parseInt(low, 10);

        var text = weatherIconToTextMap[iconName] || description;
        var notes = '';

        var notesHtml = getInner(tableHtml, '\u00A0' + day + '\u00A0<abbr title="', '<strong>');
        // console.log('notesHtml', notesHtml)
        if (!notesHtml) { // Last item
            notesHtml = getInner(tableHtml, '\u00A0' + day + '\u00A0<abbr title="', '</tbody>');
            // console.log('notesHtml', notesHtml)
        }
        var dayNotes = getInner(notesHtml, '</td>\n              <td>', '</td>');
        // console.log('dayNotes', dayNotes)
        if (notesHtml.indexOf('night">Tonight</strong>') >= 0) {
            notes = i18n("<b>Tonight:</b> %1", dayNotes);
        } else {
            var nightNotes = getInner(notesHtml, 'night"> Night\n</td>\n              <td>', '</td>');
            // console.log('nightNotes', nightNotes)
            if (nightNotes) {
                notes = i18n("%1<br><b>Night:</b> %2", dayNotes, nightNotes);
            } else { // Last item (w/ Tonight as first item)
                notes = dayNotes;
            }
            
        }
        
        // notes = dayNotes + '<br>' + nightNotes;

        
        weatherData.list.push({
            dt: dt,
            temp: {
                max: high,
                min: low,
            },
            iconName: iconName,
            text: text,
            description: description,
            notes: notes,
        });
    });

    return weatherData;
}



function parseHourlyHtml(html) {
    html = getInner(html, '<tbody>', '</tbody>');
    return parseHourlyTbody(html);
}
function parseHourlyTbody(html) {
    // Iterate all <tr>
    var cursor = 0;
    var dateStr;
    var weatherData = {
        list: []
    };
    for (var i = 0; i < 1000; i++) { // Hard limit of 1000 iterations
        var start = html.indexOf('<tr>', cursor);
        if (start == -1) {
            break;
        }
        start += '<tr>'.length;
        var end = html.indexOf('</tr>', cursor);
        var trHtml = html.substr(start, end-start);

        if (trHtml.indexOf('<th ') >= 0) {
            // Date heading
            dateStr = parseHourlyDate(trHtml);
            // console.log(dateStr);
        } else {
            // Hourly forecast
            var timeStr = parseHourlyTime(trHtml);
            var temp = parseHourlyTemp(trHtml);
            var conditions = parseHourlyConditions(trHtml);
            var dt = Math.floor(new Date(dateStr + ' ' + timeStr).getTime() / 1000);
            // console.log(dt, timeStr, conditions.icon, conditions.id, conditions.description);

            weatherData.list.push({
                dt: dt,
                main: {
                    temp: temp,
                },
                weather: [
                    {
                        icon: '',
                        iconName: conditions.icon,
                        description: conditions.description,
                    }
                ],
            });
        }

        cursor = end + '</tr>'.length;
    }
    return weatherData;
}
function parseHourlyDate(trHtml) {
    return getInner(trHtml, '>', '</');
}
function parseHourlyTime(trHtml) {
    return getInner(trHtml, '<td headers="header1" class="text-center">', '</td>');
}
function parseHourlyTemp(trHtml) {
    var str = getInner(trHtml, '<td headers="header2" class="text-center">', '</td>');
    return parseInt(str, 10);
}
function parseHourlyConditions(trHtml) {
    var td = getInner(trHtml, '<td headers="header3" class="media">', '</td>');
    var imageId = getInner(td, 'src="/weathericons/small/', '.png"');
    var text = getInner(td, '<p>', '</p>');

    return {
        id: imageId,
        icon: weatherIconMap[imageId],
        description: text,
    };
}



function getCityUrl(cityId) {
    return 'https://weather.gc.ca/city/pages/' + cityId + '_metric_e.html';
}

function updateDailyWeather(callback) {
    var url = getCityUrl(plasmoid.configuration.weather_canada_city_id);
    Utils.request(url, function(err, data, xhr) {
        if (err) return console.log('fetchDailyWeatherForecast.err', err, xhr && xhr.status, data);
        console.log('fetchDailyWeatherForecast.response');
        
        var weatherData = parseDailyHtml(data);
        // console.log(JSON.stringify(weatherData, null, '\t'));
        callback(err, weatherData);
    });
}

function getCityHourlyUrl(cityId) {
    return 'https://weather.gc.ca/forecast/hourly/' + cityId + '_metric_e.html';
}

function updateHourlyWeather(callback) {
    var url = getCityHourlyUrl(plasmoid.configuration.weather_canada_city_id);
    Utils.request(url, function(err, data, xhr) {
        if (err) return console.log('fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data);
        console.log('fetchHourlyWeatherForecast.response');
        
        var weatherData = parseHourlyHtml(data);
        // console.log(JSON.stringify(weatherData, null, '\t'));
        callback(err, weatherData);
    });
}


function parseCityList(html) {
    var lines = html.split('\n');
    var cityList = [];

    for (var i = 0; i < lines.length; i++) {
        var line = lines[i];
        if (line.indexOf('<li><a href="') !== 0) {
            continue; // <ul>/</ul>/...
        }
        var cityId = getInner(line, '<li><a href="/city/pages/', '_metric_e.html');
        var cityName = getInner(line, '_metric_e.html">', '</a></li>');
        cityList.push({
            id: cityId,
            name: cityName,
        });
    }
    return cityList;
}
function parseProvincePage(html) {
    html = getInner(html, '[Provincial Summary]</a>&nbsp;</p>\n<div class="well"><div class="row">', '</div></div>');
    return parseCityList(html);
}
