import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi
import "../code/DebugFixtures.js" as DebugFixtures

RowLayout {
    id: agendaListItem
    Layout.fillWidth: true
    anchors.left: parent.left
    anchors.right: parent.right
    spacing: 0
    property date agendaItemDate: model.date
    property bool agendaItemIsToday: false
    function checkIfToday() {
        agendaItemIsToday = timeModel.currentTime && model.date ? Shared.isSameDate(timeModel.currentTime, model.date) : false
        // console.log('checkIfToday()', agendaListItem.agendaItemIsToday, timeModel.currentTime, model.date)
    }
    Component.onCompleted: agendaListItem.checkIfToday()
    Connections {
        target: timeModel
        onLoaded: agendaListItem.checkIfToday()
        onDateChanged: agendaListItem.checkIfToday()
    }
    property bool agendaItemInProgress: agendaItemIsToday

    LinkRect {
        visible: agendaModel.showDailyWeather
        Layout.alignment: Qt.AlignTop

        Column {
            id: itemWeatherColumn
            width: appletConfig.agendaWeatherColumnWidth
            Layout.alignment: Qt.AlignTop

            FontIcon {
                visible: showWeather && plasmoid.configuration.agenda_weather_show_icon
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                source: weatherIcon
                height: plasmoid.configuration.agenda_weather_icon_height
                showOutline: plasmoid.configuration.show_outlines
                anchors {
                    left: parent.left
                    right: parent.right
                }
            }

            Text {
                id: itemWeatherText
                visible: showWeather && plasmoid.configuration.agenda_weather_show_text
                text: weatherText
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: paintedWidth > parent.width ? Text.AlignLeft  : Text.AlignHCenter
            }

            Text {
                id: itemWeatherTemps
                visible: showWeather
                text: tempHigh + '° | ' + tempLow + '°'
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: paintedWidth > parent.width ? Text.AlignLeft  : Text.AlignHCenter
            }
        }

        tooltipMainText: weatherDescription
        tooltipSubText: weatherNotes

        onLeftClicked: {
            // console.log('agendaItem.date.clicked', date)
            if (true) {
                // cfg_agenda_weather_clicked == "browser_viewcityforecast"
                WeatherApi.openCityUrl();
            }
        }
    }

    LinkRect {
        Layout.alignment: Qt.AlignTop
        width: appletConfig.agendaDateColumnWidth
        Column {
            id: itemDateColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: appletConfig.agendaColumnSpacing
            anchors.rightMargin: appletConfig.agendaColumnSpacing

            Text {
                id: itemDate
                text: Qt.formatDateTime(date, "MMM d")
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
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
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.5
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                anchors {
                    left: parent.left
                    right: parent.right
                }
                horizontalAlignment: Text.AlignRight
            }
        }

        onLeftClicked: {
            // console.log('agendaItem.date.leftClicked', date)
            if (false) {
                // cfg_agenda_date_clicked == "browser_newevent"
                Shared.openGoogleCalendarNewEventUrl(date);
            } else if (true) {
                // cfg_agenda_date_clicked == "agenda_newevent"
                newEventForm.active = !newEventForm.active
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        spacing: 0
        Item {
            Layout.fillWidth: true
        }

        Loader {
            id: newEventForm
            active: false
            visible: active

            Layout.fillWidth: true
            sourceComponent: Component {

                ColumnLayout {
                    spacing: appletConfig.agendaRowSpacing

                    Component.onCompleted: {
                        newEventText.forceActiveFocus()
                        newEventFormOpened(model, newEventCalendarId)
                    }
                    PlasmaComponents.ComboBox {
                        id: newEventCalendarId
                        Layout.fillWidth: true
                        model: [i18n("[No Calendars]")]
                    }

                    RowLayout {
                        PlasmaComponents.TextField {
                            id: newEventText
                            Layout.fillWidth: true
                            placeholderText: i18n("Eg: 9am-5pm Work")
                            onAccepted: {
                                var calendarId = newEventCalendarId.model[newEventCalendarId.currentIndex]
                                // calendarId = calendarId.calendarId ? calendarId.calendarId : calendarId
                                submitNewEventForm(calendarId, date, text)
                                text = ''
                            }
                            Keys.onEscapePressed: newEventForm.active = false
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        height: appletConfig.agendaRowSpacing // Effectively twice the padding below the form.
                    }
                }
            }
        }
        

        ColumnLayout {
            spacing: appletConfig.agendaRowSpacing
            Layout.fillWidth: true

            Repeater {
                model: events

                delegate: LinkRect {
                    id: eventListItem
                    width: undefined
                    Layout.fillWidth: true
                    Layout.preferredHeight: eventColumn.height
                    // height: eventColumn.height
                    property bool eventItemInProgress: false
                    function checkIfInProgress() {
                        eventItemInProgress = start && currentTime && end ? start.dateTime <= currentTime && currentTime <= end.dateTime : false
                        // console.log('checkIfInProgress()', start, currentTime, end)
                    }
                    Connections {
                        target: timeModel
                        onLoaded: eventListItem.checkIfInProgress()
                        onMinuteChanged: eventListItem.checkIfInProgress()
                    }
                    Component.onCompleted: eventListItem.checkIfInProgress()

                    property bool isEditing: editSummaryForm.active || editDateTimeForm.active
                    enabled: !isEditing

                    RowLayout {
                        width: parent.width

                        Rectangle {
                            Layout.preferredWidth: appletConfig.eventIndicatorWidth
                            Layout.preferredHeight: eventColumn.height
                            color: model.backgroundColor || theme.textColor
                        }

                        ColumnLayout {
                            id: eventColumn
                            Layout.fillWidth: true
                            spacing: 0

                            PlasmaComponents.Label {
                                id: eventSummary
                                text: summary
                                color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
                                font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
                                visible: !editSummaryForm.active
                                Layout.fillWidth: true

                                // Wrapping causes reflow, which causes scroll to selection to miss the selected date
                                // since it reflows after updateUI/scrollToDate is done.
                                // wrapMode: Text.Wrap
                            }

                            Loader {
                                id: editSummaryForm
                                active: false
                                visible: active
                                Layout.fillWidth: true
                                sourceComponent: Component {
                                    PlasmaComponents.TextField {
                                        id: editEventText
                                        placeholderText: i18n("Event Summary")
                                        text: summary
                                        onAccepted: {
                                            console.log('editEventText.onAccepted', text)
                                            var event = events.get(index)
                                            console.log(event)
                                            console.log(JSON.stringify(event))
                                            eventModel.setEventSummary(event.calendarId, event.id, text)
                                        }
                                        Component.onCompleted: {
                                            forceActiveFocus()
                                        }

                                        Keys.onEscapePressed: editSummaryForm.active = false
                                    }
                                }
                            }

                            Text {
                                id: eventDateTime
                                text: {
                                    Shared.formatEventDuration(model, {
                                        relativeDate: agendaItemDate,
                                        clock_24h: plasmoid.configuration.clock_24h,
                                    })
                                }
                                color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
                                opacity: eventItemInProgress ? 1 : 0.75
                                font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
                                visible: !editDateTimeForm.active
                            }

                            Loader {
                                id: editDateTimeForm
                                active: false
                                visible: active
                                Layout.fillWidth: true
                                sourceComponent: Component {
                                    RowLayout {
                                        ColumnLayout {
                                            Layout.fillWidth: true
                                            RowLayout {
                                                PlasmaComponents.TextField {
                                                    id: editStartDate
                                                    placeholderText: '31/12/2017' // Note that US/Canada is 12/31/2017
                                                    text: Qt.formatDate(model.start.dateTime)

                                                    Component.onCompleted: {
                                                        forceActiveFocus()
                                                    }

                                                    Layout.fillWidth: true
                                                    Keys.onEscapePressed: editDateTimeForm.active = false
                                                }

                                                PlasmaComponents.TextField {
                                                    id: editStartTime
                                                    placeholderText: '9:00am'
                                                    text: Qt.formatTime(model.start.dateTime)

                                                    Layout.fillWidth: true
                                                    Keys.onEscapePressed: editDateTimeForm.active = false
                                                }
                                            }
                                            PlasmaComponents.Label {
                                                text: i18n("to")
                                            }
                                            RowLayout {
                                                PlasmaComponents.TextField {
                                                    id: editEndDate
                                                    placeholderText: '31/12/2017' // Note that US/Canada is 12/31/2017
                                                    text: Qt.formatDate(model.end.dateTime)

                                                    Layout.fillWidth: true
                                                    Keys.onEscapePressed: editDateTimeForm.active = false
                                                }

                                                PlasmaComponents.TextField {
                                                    id: editEndTime
                                                    placeholderText: '10:00am'
                                                    text: Qt.formatTime(model.end.dateTime)

                                                    Layout.fillWidth: true
                                                    Keys.onEscapePressed: editDateTimeForm.active = false
                                                }
                                            }
                                        }

                                        ColumnLayout {
                                            Layout.alignment: Qt.AlignTop
                                            PlasmaComponents.CheckBox {
                                                text: i18n("All Day")
                                                Layout.minimumWidth: 0
                                            }
                                            PlasmaComponents.Button {
                                                text: i18n("Save")
                                                Layout.minimumWidth: 0
                                                onClicked: {
                                                    // ...
                                                    editDateTimeForm.active = false
                                                }
                                            }
                                            PlasmaComponents.Button {
                                                text: i18n("Discard")
                                                Layout.minimumWidth: 0
                                                onClicked: editDateTimeForm.active = false
                                            }
                                        }
                                    } // RowLayout
                                } // Component
                            } // Loader
                        } // eventColumn
                    }
                    
                    onLeftClicked: {
                        // console.log('agendaItem.event.leftClicked', start.date, mouse)
                        if (false) {
                            var event = events.get(index)
                            console.log("event", JSON.stringify(event, null, '\t'))
                            var calendar = eventModel.getCalendar(event.calendarId)
                            console.log("calendar", JSON.stringify(calendar, null, '\t'))
                            upcomingEvents.sendEventStartingNotification(model)
                        } else {
                            // cfg_agenda_event_clicked == "browser_viewevent"
                            Qt.openUrlExternally(htmlLink)
                        }
                    }

                    onLoadContextMenu: {
                        var menuItem;
                        var event = events.get(index)

                        menuItem = contextMenu.newMenuItem();
                        menuItem.text = i18n("Edit description");
                        menuItem.icon = "edit-rename"
                        menuItem.enabled = event.canEdit
                        menuItem.clicked.connect(function() {
                            editSummaryForm.active = !editSummaryForm.active
                        });
                        contextMenu.addMenuItem(menuItem);

                        // menuItem = contextMenu.newMenuItem();
                        // menuItem.text = i18n("Edit date/time");
                        // menuItem.enabled = event.canEdit
                        // menuItem.clicked.connect(function() {
                        //     editDateTimeForm.active = !editDateTimeForm.active
                        // });
                        // contextMenu.addMenuItem(menuItem);

                        var deleteMenuItem = contextMenu.newSubMenu();
                        deleteMenuItem.text = i18n("Delete Event");
                        deleteMenuItem.icon = "delete"
                        menuItem = contextMenu.newMenuItem(deleteMenuItem);
                        menuItem.text = i18n("Confirm Deletion");
                        menuItem.icon = "delete"
                        menuItem.enabled = event.canEdit
                        menuItem.clicked.connect(function() {
                            logger.debug('eventModel.deleteEvent', model.calendarId, model.id)
                            eventModel.deleteEvent(model.calendarId, model.id)
                        });
                        deleteMenuItem.enabled = event.canEdit
                        deleteMenuItem.subMenu.addMenuItem(menuItem);
                        contextMenu.addMenuItem(deleteMenuItem);

                        menuItem = contextMenu.newMenuItem();
                        menuItem.text = i18n("Edit in browser");
                        menuItem.icon = "internet-web-browser"
                        menuItem.clicked.connect(function() {
                            Qt.openUrlExternally(model.htmlLink)
                        });
                        contextMenu.addMenuItem(menuItem);
                    }

                }
            }
        }

    }
}
