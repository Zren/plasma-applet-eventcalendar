import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import QtQuick.Layouts 1.1
import QtMultimedia 5.6
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: timerView

    property int timerSeconds: 0
    property int timerDuration: 0
    property alias isRepeatingTimer: timerRepeat.checked
    property int defaultTimerWidth: 48
    property bool cfg_timer_sfx_enabled: true
    property string cfg_timer_sfx_filepath: "/usr/share/sounds/freedesktop/stereo/complete.oga"

    width: 400
    height: 100

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

            PlasmaExtras.Heading {
                id: timerLabel
                text: "0:00"
                font.pixelSize: 40
                font.pointSize: -1
            }

            PlasmaComponents.ToolButton {
                iconSource: timerTicker.running ? 'media-playback-pause' : 'media-playback-start'
                height: parent.height
                enabled: timerSeconds > 0
                onClicked: {
                    if (timerTicker.running) {
                        timerTicker.stop()
                    } else {
                        timerTicker.start()
                    }
                }
            }
            
            PlasmaComponents.Switch {
                id: timerRepeat
                text: "Repeat"
                height: parent.height
            }

            // PlasmaComponents.Switch {
            //     id: timerInTaskbar
            //     text: "Taskbar"
            //     height: parent.height
            // }
        }

        Row {
            spacing: 2

            PlasmaComponents.Button {
                text: "30s"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(30)
            }
            PlasmaComponents.Button {
                text: "1m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(60)
            }
            PlasmaComponents.Button {
                text: "5m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(5 * 60)
            }
            PlasmaComponents.Button {
                text: "10m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(10 * 60)
            }
            PlasmaComponents.Button {
                text: "15m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(15 * 60)
            }
            PlasmaComponents.Button {
                text: "30m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(30 * 60)
            }
            PlasmaComponents.Button {
                text: "45m"
                width: defaultTimerWidth
                onClicked: setDurationAndStart(45 * 60)
            }
            PlasmaComponents.Button {
                text: "1h"
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

    function setDurationAndStart(duration) {
        timerDuration = duration
        timerSeconds = duration
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
        notificationSound.play()

        if (isRepeatingTimer) {
            timerSeconds = timerDuration
            timerTicker.start()
        }
    }

    Audio {
        id: notificationSound
        source: cfg_timer_sfx_filepath
        muted: !cfg_timer_sfx_enabled
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
        operation["body"] = formatTimer(timerDuration) + " has passed";
        operation["expireTimeout"] = 2000;

        service.startOperationCall(operation);
    }
}