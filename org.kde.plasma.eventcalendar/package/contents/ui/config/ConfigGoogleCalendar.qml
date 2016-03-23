
import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../utils.js" as Utils

Item {
    id: generalPage

    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight

    property alias cfg_client_id: client_id.text
    property alias cfg_client_secret: client_secret.text
    property alias cfg_device_code: device_code.text
    property alias cfg_user_code: user_code.text
    property alias cfg_user_code_verification_url: user_code_verification_url.text
    property alias cfg_user_code_expires_at: user_code_expires_at.text
    property alias cfg_user_code_interval: user_code_interval.text
    property alias cfg_access_token: access_token.text
    property alias cfg_access_token_type: access_token_type.text
    property alias cfg_access_token_expires_at: access_token_expires_at.text
    property alias cfg_refresh_token: refresh_token.text
    property alias cfg_calendar_id_list: calendar_id_list.text
    property alias cfg_calendar_list: calendar_list.text

    function setCalendarIdList(calendarIdList) {
        cfg_calendar_id_list = calendarIdList.join(',');
    }
    function getCalendarIdList() {
        return cfg_calendar_id_list.split(',');
    }

    function setCalendarList(calendarList) {
        cfg_calendar_list = Qt.btoa(JSON.stringify(calendarList));
    }
    function getCalendarList() {
        return cfg_calendar_list ? JSON.parse(Qt.atob(cfg_calendar_list)) : [];
    }
    
    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    Layout.fillWidth: true

    ColumnLayout {
        id: pageColumn
        Layout.fillWidth: true


        PlasmaExtras.Heading {
            level: 2
            text: i18n("Login")
            color: palette.text
        }
        Item {
            width: height
            height: units.gridUnit / 2
        }
        Column {
            visible: cfg_access_token
            Text {
                text: 'Currently Synched.'
                color: "#3c763d"
            }
        }
        Column {
            visible: !cfg_access_token
            Text {
                text: 'To sync with Google Calendar'
                color: "#8a6d3b"
            }
            Text {
                text: 'Enter the following code at <a href="https://www.google.com/device">https://www.google.com/device</a>.'
                color: "#8a6d3b"
                linkColor: "#369"
                onLinkActivated: Qt.openUrlExternally(link)
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
                    cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
                }
            }
            TextField {
                id: userCodeInput

                placeholderText: "Generating Code..."
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

        PlasmaExtras.Heading {
            level: 2
            text: i18n("Calendars")
            color: palette.text
        }
        Item {
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            spacing: units.smallSpacing * 2
            Layout.fillWidth: true

            ListModel {
                id: calendarsModel

                function onCalendarsShownChange() {
                    var calendarIdList = [];
                    for (var i = 0; i < calendarsModel.count; i++) {
                        var item = calendarsModel.get(i);
                        console.log('calendarsModel', item.calendarId);
                        
                        if (item.show) {
                            calendarIdList.push(item.calendarId);
                        }
                    }

                    generalPage.setCalendarIdList(calendarIdList);
                }
            }

            Column {
                Layout.fillWidth: true

                Repeater {
                    model: calendarsModel
                    delegate: CheckBox {
                        text: name
                        checked: show
                        // style: CheckBoxStyle {
                        //     label: Item {
                        //         Rectangle {
                        //             anchors.fill: labelText
                        //             color: backgroundColor
                        //         }
                        //         Text {
                        //             id: labelText
                        //             color: foregroundColor
                        //             text: control.text
                        //         }
                        //     }
                            
                        // }

                        onClicked: {
                            calendarsModel.setProperty(index, 'show', checked)
                            // model.show = checked
                            console.log(index, model.calendarId, model.show, checked);

                            calendarsModel.onCalendarsShownChange()
                        }
                    }
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("calendar_id_list:")
                }
                TextField {
                    id: calendar_id_list
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("calendar_list:")
                }
                TextField {
                    id: calendar_list
                    Layout.fillWidth: true
                }
            }
        }

        //--- Advanced

        PlasmaExtras.Heading {
            visible: showDebug
            level: 2
            text: i18n("Applet")
            color: palette.text
        }
        Item {
            visible: showDebug
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            spacing: units.smallSpacing * 2
            Layout.fillWidth: true
            

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("client_id:")
                }
                TextField {
                    id: client_id
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("client_secret:")
                }
                TextField {
                    id: client_secret
                    Layout.fillWidth: true
                }
            }
        }



        PlasmaExtras.Heading {
            visible: showDebug
            level: 2
            text: i18n("User Code")
            color: palette.text
        }
        Item {
            visible: showDebug
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            spacing: units.smallSpacing * 2
            Layout.fillWidth: true
            

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("device_code:")
                }
                TextField {
                    id: device_code
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("user_code:")
                }
                TextField {
                    id: user_code
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("user_code_verification_url:")
                }
                TextField {
                    id: user_code_verification_url
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("user_code_expires_at:")
                }
                TextField {
                    id: user_code_expires_at
                    Layout.fillWidth: true
                }
            }


            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("user_code_interval:")
                }
                TextField {
                    id: user_code_interval
                    Layout.fillWidth: true
                }
            }
        }



        PlasmaExtras.Heading {
            level: 2
            text: i18n("Token")
            color: palette.text
        }
        Item {
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            spacing: units.smallSpacing * 2
            Layout.fillWidth: true
            

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("access_token:")
                }
                TextField {
                    id: access_token
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("access_token_type:")
                }
                TextField {
                    id: access_token_type
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("access_token_expires_at:")
                }
                TextField {
                    id: access_token_expires_at
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("refresh_token:")
                }
                TextField {
                    id: refresh_token
                    Layout.fillWidth: true
                }
            }
        }


    }


    Timer {
        id: accessTokenTimer
        interval: 5000
        running: false
        repeat: true
        onTriggered: pollAccessToken()
    }

    function fetchGCalCalendars(args, callback) {
        var url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList';
        Utils.getJSON({
            url: url,
            headers: {
                "Authorization": "Bearer " + args.access_token,
            }
        }, function(err, data, xhr) {
            console.log('fetchGCalEvents.response', err, data, xhr.status);
            if (!err && data && data.error) {
                return callback(data, null, xhr);
            }
            callback(err, data, xhr);
        });
    }

    function updateGCalCalendars() {
        console.log('access_token', cfg_access_token, plasmoid.configuration.access_token)
        fetchGCalCalendars({
            access_token: cfg_access_token || plasmoid.configuration.access_token,
        }, function(err, data, xhr) {
            setCalendarList(data.items);

            var calendarIdList = getCalendarIdList();

            var calendarList = getCalendarList();
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
            
        });
    }

    function pollAccessToken() {
        var url = 'https://www.googleapis.com/oauth2/v4/token';
        Utils.post({
            url: url,
            data: {
                client_id: cfg_client_id,
                client_secret: cfg_client_secret,
                code: cfg_device_code,
                grant_type: 'http://oauth.net/grant_type/device/1.0',
            },
        }, function(err, data) {
            console.log('test', err, data)
            data = JSON.parse(data);
            console.log('data', JSON.stringify(data, null, '\t'));

            if (data.error) {
                // Not yet ready
                return;
            }

            accessTokenTimer.stop();

            cfg_access_token = data.access_token;
            cfg_access_token_type = data.token_type;
            cfg_access_token_expires_at = Date.now() + data.expires_in * 1000;
            cfg_refresh_token = data.refresh_token;

            updateGCalCalendars();
        });
    }

    function getUserCode(callback) {
        var url = 'https://accounts.google.com/o/oauth2/device/code';
        Utils.post({
            url: url,
            data: {
                client_id: plasmoid.configuration.client_id,
                scope: 'https://www.googleapis.com/auth/calendar',
            },
        }, callback);
    }

    function generateUserCodeAndPoll() {
        getUserCode(function(err, data) {
            data = JSON.parse(data);
            console.log('data', JSON.stringify(data, null, '\t'));

            cfg_device_code = data.device_code;
            cfg_user_code = data.user_code;
            cfg_user_code_verification_url = data.verification_url;
            cfg_user_code_expires_at = Date.now() + data.expires_in * 1000;
            cfg_user_code_interval = data.interval;

            userCodeInput.text = data.user_code;

            accessTokenTimer.interval = data.interval * 1000;
            accessTokenTimer.start();
        });
    }

    Component.onCompleted: {
        // cfg_* are not yet populated.

        console.log('access_token', plasmoid.configuration.access_token);
        if (plasmoid.configuration.access_token) {
            updateGCalCalendars();
        } else {
            console.log('client_id', plasmoid.configuration.client_id);
            generateUserCodeAndPoll();
        }
    }
}