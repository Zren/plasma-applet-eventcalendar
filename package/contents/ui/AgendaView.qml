import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: agendaView

    //anchors.margins: units.largeSpacing
    property int spacing: units.largeSpacing

    property int showNextNumDays: 14
    property bool clipPastEvents: false


    ListModel {
        id: agendaModel
    }

    width: 400
    height: 400

    // Testing with qmlview
    Rectangle {
        visible: !popup
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }
    
    ListView {
        id: agenda
        model: agendaModel
        anchors.fill: parent
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds

        // Don't bother garbage collecting
        // GC or Reloading the weather images is very slow.
        cacheBuffer: 10000000 

        delegate: RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Column {
                width: 50
                Layout.alignment: Qt.AlignTop

                Item {
                    visible: showWeather
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    height: 16

                    Image {
                        id: itemWeatherIcon
                        source: weatherIcon ? "images/" + weatherIcon + ".svg" : ""
                        anchors.centerIn: parent
                        cache: true
                        asynchronous: true
                        sourceSize.width: parent.height
                        sourceSize.height: parent.height
                    }
                }

                Text {
                    id: itemWeatherText
                    visible: showWeather
                    text: weatherText
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.5
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    id: itemWeatherTemps
                    visible: showWeather
                    text: tempHigh + '° | ' + tempLow + '°'
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.5
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            Column {
                id: itemDateColumn
                width: 50
                Layout.alignment: Qt.AlignTop

                Text {
                    id: itemDate
                    text: Qt.formatDateTime(date, "MMM d")
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.75
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignRight

                    // MouseArea {
                    //     anchors.fill: itemDateColumn
                    //     onClicked: {
                    //         newEventInput.forceActiveFocus()
                    //     }
                    // }
                }

                Text {
                    id: itemDay
                    text: Qt.formatDateTime(date, "ddd")
                    color: PlasmaCore.ColorScope.textColor
                    opacity: 0.5
                    anchors {
                        left: parent.left
                        right: parent.right
                    }
                    horizontalAlignment: Text.AlignRight
                }
            }

            Column {
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true

                Repeater {
                    model: events

                    delegate: Column {
                        id: eventColumn

                        Text {
                            id: eventSummary
                            text: summary
                            color: PlasmaCore.ColorScope.textColor
                        }

                        Text {
                            id: eventDateTime
                            text: start.date ? "All Day" : Qt.formatDateTime(start.dateTime, "h") + " - " + Qt.formatDateTime(end.dateTime, "h AP")
                            color: PlasmaCore.ColorScope.textColor
                            opacity: 0.75
                        }

                        // Spacer
                        Item {
                            width: parent.width
                            height: 10
                        }
                    }
                }
            }
        }
    }

    function parseGCalEvents(data) {
        agendaModel.clear();

        if (!(data && data.items))
            return;

        // var eventItemList = [];
        // var timeZoneOffset = new Date().getTimezoneOffset()/60;
        // timeZoneOffset = 'Z' + (timeZoneOffset > 0 ? '-' : '+') + timeZoneOffset + '00';
        // console.log(timeZoneOffset);
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];

            if (eventItem.start.date) {
                eventItem.start.dateTime = new Date(eventItem.start.date + ' 00:00:00');
            } else {
                eventItem.start.dateTime = new Date(eventItem.start.dateTime);
            }
            // console.log(eventItem.start.dateTime, eventItem.summary);

            if (eventItem.end.date) {
                eventItem.end.dateTime = new Date(eventItem.end.date + ' 00:00:00');
            } else {
                eventItem.end.dateTime = new Date(eventItem.end.dateTime);
            }

            // eventItemList.push(eventItem);
        }
        data.items.sort(function(a,b) { return a.start.dateTime - b.start.dateTime; });

        // for (var i = 0; i < data.items.length; i++) {
        //     var eventItem = data.items[i];
        //     console.log(eventItem.start.dateTime, eventItem.summary);
        // }

        var agendaItemList = [];
        var agendaItem;
        for (var i = 0; i < data.items.length; i++) {
            var eventItem = data.items[i];
            // console.log(agendaItem && agendaItem.date.getDate(), eventItem.start.dateTime.getDate());
            var isSameDay = agendaItem && agendaItem.date.getDate() == eventItem.start.dateTime.getDate();
            if (!agendaItem || !isSameDay) {
                if (agendaItem) {
                    agendaItemList.push(agendaItem);
                }
                agendaItem = {
                    date: eventItem.start.dateTime,
                    events: [],
                    showWeather: false,
                    tempLow: 0,
                    tempHigh: 0,
                    weatherIcon: "",
                    weatherText: "",
                };
            }

            agendaItem.events.push(eventItem);
        }
        if (agendaItem) {
            agendaItemList.push(agendaItem);
        }

        if (showNextNumDays > 0) {
            var today = new Date();
            var end = new Date().setDate(today.getDate() + showNextNumDays);
            for (var day = new Date(today); day <= end; day.setDate(day.getDate() + 1)) {
                // console.log(day);

                // Check if agenedaItem with this date already exists.
                var index = -1;
                for (var i = 0; i < agendaItemList.length; i++) {
                    var agendaItem = agendaItemList[i];
                    if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() == agendaItem.date.getDate()) {
                        index = i;
                        break;
                    }
                }
                if (index >= 0) {
                    // It does, so skip.
                    continue;
                }

                // It doesn't, so we need to insert an item.
                var newAgendaItem = {
                    date: new Date(day),
                    events: [],
                    showWeather: false,
                    tempLow: 0,
                    tempHigh: 0,
                    weatherIcon: "",
                    weatherText: "",
                };

                // Insert before the agendaItem with a higher date.
                for (var i = 0; i < agendaItemList.length; i++) {
                    var agendaItem = agendaItemList[i];
                    if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() < agendaItem.date.getDate()) {
                        index = i;
                        break;
                    }
                }

                if (index >= 0) {
                    // Insert at index
                    agendaItemList.splice(i, 0, newAgendaItem);
                } else {
                    // Append
                    agendaItemList.push(newAgendaItem);
                }
                // console.log('uneventfulDay:', day);
            }
        }
        
        if (clipPastEvents) {
            // Remove calendar events before today.
            for (var i = 0; i < agendaItemList.length; i++) {
                var agendaItem = agendaItemList[i];
                if (agendaItem.date < today) {
                    // console.log('removed agendaItem:', agendaItem.date)
                    agendaItemList.splice(i, 1);
                    i--;
                }
            }
        }

        for (var i = 0; i < agendaItemList.length; i++) {
            agendaModel.append(agendaItemList[i]);
        }
    }

    function parseWeatherForecast(data) {
        if (!(data && data.list))
            return;

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
            '02n': 'weather-few-clouds',
            '03n': 'weather-clouds',
            '04n': 'weather-overcast',
            '09n': 'weather-showers-scattered',
            '10n': 'weather-showers',
            '11n': 'weather-storm',
            '13n': 'weather-snow',
            '50n': 'weather-fog',
        };

        for (var j = 0; j < data.list.length; j++) {
            var forecastItem = data.list[j];
            var day = new Date(forecastItem.dt * 1000);

            for (var i = 0; i < agendaModel.count; i++) {
                var agendaItem = agendaModel.get(i);
                if (day.getMonth() == agendaItem.date.getMonth() && day.getDate() == agendaItem.date.getDate()) {
                    // console.log(day);
                    agendaItem.tempLow = Math.floor(forecastItem.temp.min);
                    agendaItem.tempHigh = Math.ceil(forecastItem.temp.max);
                    agendaModel.setProperty(i, 'tempLow', Math.floor(forecastItem.temp.min));
                    agendaModel.setProperty(i, 'tempHigh', Math.ceil(forecastItem.temp.max));
                    var weatherIcon = weatherIconMap[forecastItem.weather[0].icon] || 'weather-severe-alert';
                    agendaModel.setProperty(i, 'weatherIcon', weatherIcon);
                    agendaModel.setProperty(i, 'weatherText', forecastItem.weather[0].main);
                    agendaModel.setProperty(i, 'showWeather', true);
                    break;
                }
            }
        }
    }

    Component.onCompleted: {
        parseGCalEvents({ "items": [], });
        parseWeatherForecast({ "list": [], });
    }
}
