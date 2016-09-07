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
    '': 'weather-overcast',
    '': 'weather-showers-scattered-night',
    '': 'weather-showers-night',
    '39': 'weather-storm-night', // Chance of showers. Risk of thunderstorms
    '': 'weather-snow',
    '': 'weather-fog',
};

function getInner(html, a, b) {
    var start = html.indexOf(a) + a.length;
    var end = html.indexOf(b, start);
    return html.substr(start, end-start);
}
function parseHtml(html) {
    html = getInner(html, '<tbody>', '</tbody>');
    return parseTbody(html);
}
function parseTbody(html) {
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
            dateStr = parseDate(trHtml);
            console.log(dateStr);
        } else {
            // Hourly forecast
            var timeStr = parseTime(trHtml);
            var temp = parseTemp(trHtml);
            var conditions = parseConditions(trHtml);
            var dt = Math.floor(new Date(dateStr + ' ' + timeStr).getTime() / 1000);
            console.log(dt, timeStr, conditions.icon, conditions.id, conditions.description);

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
function parseDate(trHtml) {
    return getInner(trHtml, '>', '</');
}
function parseTime(trHtml) {
    return getInner(trHtml, '<td headers="header1" class="text-center">', '</td>');
}
function parseTemp(trHtml) {
    var str = getInner(trHtml, '<td headers="header2" class="text-center">', '</td>');
    return parseInt(str, 10);
}
function parseConditions(trHtml) {
    var td = getInner(trHtml, '<td headers="header3" class="media">', '</td>');
    var imageId = getInner(td, 'src="/weathericons/small/', '.png"');
    var text = getInner(td, '<p>', '</p>');

    return {
        id: imageId,
        icon: weatherIconMap[imageId],
        description: text,
    };
}



function updateDailyWeather(callback) {
    callback('not impletemented')
}

function updateHourlyWeather(callback) {
    var url = getCityUrl(plasmoid.configuration.weather_canada_city_id);
    Utils.request(url, function(err, data, xhr) {
        if (err) return console.log('fetchHourlyWeatherForecast.err', err, xhr && xhr.status, data);
        console.log('fetchHourlyWeatherForecast.response');
        
        var weatherData = parseHtml(data);
        // console.log(JSON.stringify(weatherData, null, '\t'));
        callback(err, weatherData);
    });
}

function getCityUrl(cityId) {
    return 'https://weather.gc.ca/forecast/hourly/' + cityId + '_metric_e.html';
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
