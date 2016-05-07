function getEventData() {
    var debugEventData = {
        "items": []
    };
    function addEvent(summary, start, end) {
        debugEventData.items.push({
            "kind": "calendar#event",
            "etag": "\"2561779720126000\"",
            "id": "a1a1a1a1a1a1a1a1a1a1a1a1a1_20160325",
            "status": "confirmed",
            "htmlLink": "https://www.google.com/calendar/event?eid=aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa&ctz=Etc/UTC",
            "created": "2008-03-24T22:34:26.000Z",
            "updated": "2010-08-04T02:44:20.063Z",
            "summary": summary,
            "start": start,
            "end": end,
            "recurringEventId": "a1a1a1a1a1a1a1a1a1a1a1a1a1",
            "originalStartTime": {
                "date": "2016-03-25"
            },
            "transparency": "transparent",
            "iCalUID": "a1a1a1a1a1a1a1a1a1a1a1a1a1@google.com",
            "sequence": 0,
            "reminders": {
                "useDefault": false
            },

            // Optional
            "backgroundColor": "#9a9cff" // We apply the calendar.backgroundColor
        });
    }

    function dateString(d) {
        return d.toISOString().substr(0, 10)
    }
    function nowPlus(n) {
        var d = new Date();
        d.setDate(d.getDate() + n);
        return d;
    }
    function addAllDayTestEvent(summary, startDaysFromNow, endDaysFromNow) {
        var start = dateString(nowPlus(startDaysFromNow));
        var end = dateString(nowPlus(endDaysFromNow));
        addEvent(summary, {date: start }, {date: end });
    }

    addEvent("Multiday Event", {date: "2016-05-10"}, {date: "2016-05-30"});
    addAllDayTestEvent("Dude's Birthday", 0, 1);
    addAllDayTestEvent("Dudette's Birthday", 1, 2);
    addAllDayTestEvent("Multiday Event", 3, 5);
    return debugEventData;
}

function getDailyWeatherData() {
    var debugWeatherData = {
        "city": {
            "id": 1,
            "name": "Area 51",
            "coord": {
                "lon": 0.249672,
                "lat": 0.550098
            },
            "country": "CA",
            "population": 0
        },
        "cod": "200",
        "message": 0.0275,
        "cnt": 7,
        "list": [
            {
                "dt": Date.now()/1000,
                "temp": {
                    "day": 5.3,
                    "min": -6.14,
                    "max": 5.43,
                    "night": -6.14,
                    "eve": 1.01,
                    "morn": 5.3
                },
                "pressure": 1006.93,
                "humidity": 49,
                "weather": [
                    {
                    "id": 800,
                    "main": "Clear",
                    "description": "clear sky",
                    "icon": "01d"
                    }
                ],
                "speed": 6.82,
                "deg": 327,
                "clouds": 0
            },
        ],
    };
    return debugWeatherData;
}