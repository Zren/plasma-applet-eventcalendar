import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import QtQuick.Layouts 1.1
import QtMultimedia 5.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: timerView

    property int timerSeconds: 0
    property int timerDuration: 0
    property int defaultTimerWidth: 48
    property alias cfg_timer_repeats: timerRepeat.isChecked
    property alias cfg_timer_sfx_enabled: timerSfxEnabled.isChecked
    property string cfg_timer_sfx_filepath: "/usr/share/sounds/freedesktop/stereo/complete.oga"

    // width: 400
    // height: 100

    // Testing with qmlview
    Rectangle {
        visible: typeof popup === 'undefined'
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }

    Column {
        spacing: 4

        Row {
            spacing: 10

            PlasmaComponents.ToolButton {
                id: timerLabel
                text: "0:00"
                iconSource: {
                    if (timerSeconds == 0) {
                        return 'chronometer';
                    } else if (timerTicker.running) {
                        return 'chronometer-pause';
                    } else {
                        return 'chronometer-start';
                    }
                }
                font.pixelSize: 40
                font.pointSize: -1
                anchors.verticalCenter: parent.verticalCenter
                tooltip: {
                    var s = "";
                    if (timerSeconds > 0) {
                        if (timerTicker.running) {
                            s += i18n("Pause Timer");
                        } else {
                            s += i18n("Start Timer");
                        }
                        s += "\n";
                    }
                    s += i18n("Scroll to add to duration");
                    return s;
                }

                onClicked: {
                    if (timerTicker.running) {
                        timerTicker.stop()
                    } else if (timerSeconds > 0) {
                        timerTicker.start()
                    } else { // timerSeconds == 0
                        // ignore
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.MiddleButton

                    onWheel: {
                        var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                        if (delta > 0) {
                            setDuration(timerDuration + 60)
                            timerTicker.stop()
                        } else if (delta < 0) {
                            setDuration(timerDuration - 60)
                            timerTicker.stop()
                        }
                    }
                }
            }
            
            ColumnLayout {
                anchors.bottom: parent.bottom
                
                PlasmaComponents.ToolButton {
                    id: timerRepeat
                    property bool isChecked: false // New property to avoid checked=pressed theming.
                    iconSource: isChecked ? 'media-playlist-repeat' : 'gtk-stop'
                    text: i18n("Repeat")
                    onClicked: {
                        isChecked = !isChecked
                        plasmoid.configuration.timer_repeats = isChecked
                    }
                }

                PlasmaComponents.ToolButton {
                    id: timerSfxEnabled
                    property bool isChecked: false // New property to avoid checked=pressed theming.
                    iconSource: isChecked ? 'audio-volume-high' : 'dialog-cancel'
                    text: i18n("Sound")
                    onClicked: {
                        isChecked = !isChecked
                        plasmoid.configuration.timer_sfx_enabled = isChecked
                    }
                }
            }
            
        }

        Row {
            spacing: 2

            PlasmaComponents.Button {
                text: i18n("30s")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(30)
            }
            PlasmaComponents.Button {
                text: i18n("1m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(60)
            }
            PlasmaComponents.Button {
                text: i18n("5m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(5 * 60)
            }
            PlasmaComponents.Button {
                text: i18n("10m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(10 * 60)
            }
            PlasmaComponents.Button {
                text: i18n("15m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(15 * 60)
            }
            PlasmaComponents.Button {
                text: i18n("30m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(30 * 60)
            }
            PlasmaComponents.Button {
                text: i18n("45m")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(45 * 60)
            }
            PlasmaComponents.Button {
                text: i18n("1h")
                width: defaultTimerWidth
                onClicked: setDurationAndStart(60 * 60)
            }
        }
    }


    Component.onCompleted: {
        timerView.forceActiveFocus()

        // Debug in qmlviewer
        if (typeof popup === 'undefined') {
            timerView.timerDuration = 3
            cfg_timer_repeats = true
            cfg_timer_sfx_enabled = true
            timerTicker.start()
        }
    }

    Timer {
        id: timerTicker
        interval: 1000
        running: false
        repeat: true

        onTriggered: {
            timerView.timerSeconds -= 1
        }
    }

    function setDuration(duration) {
        if (duration <= 0) {
            return
        }
        timerDuration = duration
        timerSeconds = duration
    }

    function setDurationAndStart(duration) {
        setDuration(duration)
        timerTicker.restart()
    }

    onTimerDurationChanged: {
        timerSeconds = timerDuration
    }

    onTimerSecondsChanged: {
        // console.log('onTimerSecondsChanged', timerSeconds)
        timerLabel.text = formatTimer(timerSeconds)

        if (timerSeconds <= 0) {
            onTimerFinished()
        }
    }

    function formatTimer(nSeconds) {
        // returns "1:00:00" or "10:00" or "0:01"
        var hours = Math.floor(nSeconds / 3600);
        var minutes = Math.floor((nSeconds - hours*3600) / 60);
        var seconds = nSeconds - hours*3600 - minutes*60;
        var s = "" + (seconds < 10 ? "0" : "") + seconds;
        s = minutes + ":" + s
        if (hours > 0) {
            s = hours + ":" + (minutes < 10 ? "0" : "") + s
        }
        return s
    }

    function onTimerFinished() {
        timerTicker.stop()
        createNotification()
        if (cfg_timer_sfx_enabled) {
            notificationSound.source = cfg_timer_sfx_filepath
            notificationSound.play()
        }

        if (cfg_timer_repeats) {
            timerSeconds = timerDuration
            timerTicker.start()
        }
    }

    Audio {
        id: notificationSound

        onStopped: {
            // source = ""
        }
    }

    PlasmaCore.DataSource {
        id: notificationSource
        engine: "notifications"
        connectedSources: "org.freedesktop.Notifications"
    }

    function createNotification() {
        // https://github.com/KDE/plasma-workspace/blob/master/dataengines/notifications/notifications.operations
        var service = notificationSource.serviceForSource("notification");
        var operation = service.operationDescription("createNotification");

        operation.appName = i18n("Timer");
        operation["appIcon"] = "chronometer";
        operation.summary = i18n("Timer finished");
        operation["body"] = i18n("%1 has passed", formatTimer(timerDuration));
        operation["expireTimeout"] = 2000;

        service.startOperationCall(operation);
    }
}