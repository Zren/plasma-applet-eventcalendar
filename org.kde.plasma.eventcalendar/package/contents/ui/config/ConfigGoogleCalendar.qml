import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../utils.js" as Utils
import ".."
import "../lib"

ConfigPage {
    id: page

    GoogleCalendarSession {
        id: session

        onCalendarListChanged: {
            console.log('onCalendarListChanged')
            calendarsModel.clear()
            for (var i = 0; i < calendarList.length; i++) {
                var item = calendarList[i];
                // console.log(JSON.stringify(item));
                var isShowned = calendarIdList.indexOf(item.id) >= 0;
                calendarsModel.append({
                    calendarId: item.id, 
                    name: item.summary,
                    description: item.description,
                    backgroundColor: item.backgroundColor,
                    foregroundColor: item.foregroundColor,
                    show: isShowned,
                });
                console.log(item.summary, isShowned, item.id);
            }
            calendarsModel.onCalendarsShownChange()
        }
    }


    HeaderText {
        text: i18n("Login")
    }
    Column {
        visible: session.accessToken
        Text {
            text: i18n("Currently Synched.")
            color: "#3c763d"
        }
        Button {
            text: i18n("Logout")
            onClicked: {
                session.reset()
                calendarsModel.clear()
            }
        }
    }
    Column {
        visible: !session.accessToken
        Text {
            text: i18n("To sync with Google Calendar")
            color: "#8a6d3b"
        }
        LinkText {
            text: i18n("Enter the following code at <a href=\"https://www.google.com/device\">https://www.google.com/device</a>.")
            color: "#8a6d3b"
        }
        TextField {
            id: userCodeInput

            placeholderText: i18n("Generating Code...")
            text: session.userCode
            readOnly: true

            onFocusChanged: selectAll()

            style: TextFieldStyle {
                textColor: "#111"
                background: Rectangle {
                    color: "#eee"
                }
            }
        }
    }

    HeaderText {
        text: i18n("Calendars")
    }
    ColumnLayout {
        spacing: units.smallSpacing * 2
        Layout.fillWidth: true

        ListModel {
            id: calendarsModel

            function onCalendarsShownChange() {
                console.log('onCalendarsShownChange')
                var calendarIdList = [];
                for (var i = 0; i < calendarsModel.count; i++) {
                    var item = calendarsModel.get(i);
                    console.log('calendarsModel', item.calendarId);
                    
                    if (item.show) {
                        calendarIdList.push(item.calendarId);
                    }
                }

                // page.setCalendarIdList(calendarIdList);
                session.calendarIdList = calendarIdList
            }
        }

        ColumnLayout {
            Layout.fillWidth: true

            Repeater {
                model: calendarsModel
                delegate: CheckBox {
                    text: name
                    checked: show
                    style: CheckBoxStyle {
                        label: RowLayout {
                            Rectangle {
                                Layout.fillHeight: true
                                Layout.preferredWidth: height
                                color: backgroundColor
                            }
                            Label {
                                id: labelText
                                text: control.text
                            }
                        }
                        
                    }

                    onClicked: {
                        calendarsModel.setProperty(index, 'show', checked)
                        // model.show = checked
                        console.log(index, model.calendarId, model.show, checked);

                        calendarsModel.onCalendarsShownChange()
                    }
                }
            }
        }
    }

    HeaderText {
        text: i18n("Misc")
    }
    ColumnLayout {

        RowLayout {
            Label {
                text: i18n("Refresh events every: ")
            }
            
            SpinBox {
                id: events_pollinterval

                suffix: i18ncp("Polling interval in minutes", "min", "min", value)
                minimumValue: 5
                maximumValue: 90
            }
        }
    }

    Component.onCompleted: {
        if (!session.accessToken) {
            session.generateUserCodeAndPoll()
        } else {
            session.calendarListChanged()
        }
    }
}
