import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: timerView

    property int timerSeconds: 0
    property int timerDuration: 0
    property alias isRepeatingTimer: timerRepeat.checked

    width: 400
    height: 100

    // Testing with qmlview
    Rectangle {
        visible: !popup
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

            PlasmaComponents.Button {
                text: "Stop"
                width: 60
                height: parent.height
                onClicked: resetTimer()
            }
            
            PlasmaComponents.Switch {
                id: timerRepeat
                text: "Repeat"
                height: parent.height
                checked: plasmoid.configuration.timer_repeats
            }

            PlasmaComponents.Switch {
                id: timerInTaskbar
                text: "Taskbar"
                height: parent.height
                checked: plasmoid.configuration.timer_in_taskbar
            }
        }

        Row {
            spacing: 10

            PlasmaComponents.Button {
                text: "30s"
                width: 40
                onClicked: setDurationAndStart(30)
            }
            PlasmaComponents.Button {
                text: "1m"
                width: 40
                onClicked: setDurationAndStart(60)
            }
            PlasmaComponents.Button {
                text: "5m"
                width: 40
                onClicked: setDurationAndStart(5 * 60)
            }
            PlasmaComponents.Button {
                text: "10m"
                width: 40
                onClicked: setDurationAndStart(10 * 60)
            }
            PlasmaComponents.Button {
                text: "15m"
                width: 40
                onClicked: setDurationAndStart(15 * 60)
            }
            PlasmaComponents.Button {
                text: "30m"
                width: 40
                onClicked: setDurationAndStart(30 * 60)
            }
            PlasmaComponents.Button {
                text: "45m"
                width: 40
                onClicked: setDurationAndStart(45 * 60)
            }
            PlasmaComponents.Button {
                text: "1h"
                width: 40
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

    function resetTimer() {
        timerDuration = 0
        timerSeconds = 0
        timerTicker.stop()
    }

    onTimerDurationChanged: {
        timerSeconds = timerDuration
    }

    onTimerSecondsChanged: {
        console.log('onTimerSecondsChanged', timerSeconds)
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
        return s
    }

    function onTimerFinished() {
        timerTicker.stop()
        createNotification()

        if (isRepeatingTimer) {
            timerSeconds = timerDuration
            timerTicker.start()
        }
    }

    PlasmaCore.DataSource {
        id: notificationSource
        engine: "notifications"
        connectedSources: "org.freedesktop.Notifications"
    }

    function createNotification() {
        var service = notificationSource.serviceForSource("notification");
        var operation = service.operationDescription("createNotification");

        operation.appName = i18n("Timer");
        operation["appIcon"] = "chronometer";
        operation.summary = i18n("Timer finished");
        operation["body"] = formatTimer(timerDuration) + " has passed";
        operation["timeout"] = 2000;
        operation["transient"] = true;

        service.startOperationCall(operation);
    }
}