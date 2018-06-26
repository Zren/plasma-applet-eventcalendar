import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles.Plasma 2.0 as Styles
import QtQuick.Layouts 1.1
import QtMultimedia 5.4
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras


Item {
    id: timerView

    property int timerSeconds: 0
    property int timerDuration: 0
    property alias timerRepeats: timerRepeatsButton.isChecked
    property alias timerSfxEnabled: timerSfxEnabledButton.isChecked

    property bool setTimerViewVisible: false

    implicitHeight: timerButtonView.height

    property var defaultTimers: [
        {
            label: i18n("30s"),
            seconds: 30,
        },
        {
            label: i18n("1m"),
            seconds: 60,
        },
        {
            label: i18n("5m"),
            seconds: 5 * 60,
        },
        {
            label: i18n("10m"),
            seconds: 10 * 60,
        },
        {
            label: i18n("15m"),
            seconds: 15 * 60,
        },
        {
            label: i18n("20m"),
            seconds: 20 * 60,
        },
        {
            label: i18n("30m"),
            seconds: 30 * 60,
        },
        {
            label: i18n("45m"),
            seconds: 45 * 60,
        },
        {
            label: i18n("1h"),
            seconds: 60 * 60,
        },
    ]

    ColumnLayout {
        id: timerButtonView
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: 4
        
        opacity: timerView.setTimerViewVisible ? 0 : 1
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        onWidthChanged: {
            // console.log('timerButtonView.width', width)
            bottomRow.updatePresetVisibilities()
        }


        RowLayout {
            id: topRow
            spacing: 10 * units.devicePixelRatio
            property int contentsWidth: timerLabel.width + topRow.spacing + toggleButtonColumn.Layout.preferredWidth
            property bool contentsFit: timerButtonView.width >= contentsWidth

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
                font.pixelSize: appletConfig.timerClockFontHeight
                font.pointSize: -1
                Layout.alignment: Qt.AlignVCenter
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
                    acceptedButtons: Qt.RightButton
                    anchors.fill: parent

                    // onClicked: contextMenu.show(mouse.x, mouse.y)
                    onClicked: contextMenu.showBelow(timerLabel)
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
                id: toggleButtonColumn
                Layout.alignment: Qt.AlignBottom
                Layout.minimumWidth: sizingButton.height
                Layout.preferredWidth: sizingButton.implicitWidth

                PlasmaComponents.ToolButton {
                    id: sizingButton
                    text: "Test"
                    visible: false
                }
                
                PlasmaComponents.ToolButton {
                    id: timerRepeatsButton
                    property bool isChecked: plasmoid.configuration.timer_repeats // New property to avoid checked=pressed theming.
                    iconSource: isChecked ? 'media-playlist-repeat' : 'gtk-stop'
                    text: topRow.contentsFit ? i18n("Repeat") : ""
                    onClicked: {
                        isChecked = !isChecked
                        plasmoid.configuration.timer_repeats = isChecked
                    }

                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        enabled: !topRow.contentsFit
                        mainText: i18n("Repeat")
                        location: PlasmaCore.Types.LeftEdge
                    }
                }

                PlasmaComponents.ToolButton {
                    id: timerSfxEnabledButton
                    property bool isChecked: plasmoid.configuration.timer_sfx_enabled // New property to avoid checked=pressed theming.
                    iconSource: isChecked ? 'audio-volume-high' : 'dialog-cancel'
                    text: topRow.contentsFit ? i18n("Sound") : ""
                    onClicked: {
                        isChecked = !isChecked
                        plasmoid.configuration.timer_sfx_enabled = isChecked
                    }

                    PlasmaCore.ToolTipArea {
                        anchors.fill: parent
                        enabled: !topRow.contentsFit
                        mainText: i18n("Sound")
                        location: PlasmaCore.Types.LeftEdge
                    }
                }
            }
            
        }

        RowLayout {
            id: bottomRow
            spacing: Math.floor(2 * units.devicePixelRatio)

            // onWidthChanged: console.log('row.width', width)

            Repeater {
                id: defaultTimerRepeater
                model: defaultTimers

                TimerPresetButton {
                    text: i18n(modelData.label)
                    onClicked: setDurationAndStart(modelData.seconds)
                }
            }

            function updatePresetVisibilities() {
                var availableWidth = timerButtonView.width
                var w = 0
                for (var i = 0; i < defaultTimerRepeater.count; i++) {
                    var item = defaultTimerRepeater.itemAt(i)
                    var itemWidth = item.Layout.minimumWidth
                    if (i > 0) {
                        itemWidth += bottomRow.spacing
                    }
                    if (w + itemWidth <= availableWidth) {
                        item.visible = true
                    } else {
                        item.visible = false
                    }
                    w += itemWidth
                    // console.log('updatePresetVisibilities', i, item.Layout.minimumWidth, item.visible, itemWidth, availableWidth)
                }
            }
        }
    }

    Loader {
        id: setTimerViewLoader
        anchors.fill: parent
        source: "TimerInputView.qml"
        active: timerView.setTimerViewVisible
        opacity: timerView.setTimerViewVisible ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }


    Component.onCompleted: {
        timerView.forceActiveFocus()

        // Debug in qmlviewer
        if (typeof popup === 'undefined') {
            timerView.timerDuration = 3
            timerRepeats = true
            sfxEnabled = true
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
        if (duration > 0) {
            timerTicker.restart()
        }
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
        if (timerSfxEnabled) {
            notificationSound.source = plasmoid.configuration.timer_sfx_filepath
            notificationSound.play()
        }

        if (timerRepeats) {
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


    // https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmacomponents/qmenu.cpp
    // Example: https://github.com/KDE/plasma-desktop/blob/master/applets/taskmanager/package/contents/ui/ContextMenu.qml
    PlasmaComponents.ContextMenu {
        id: contextMenu

        function newSeperator() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu)
        }
        function newMenuItem() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu)
        }

        function loadDynamicActions() {
            contextMenu.clearMenuItems()

            // Repeat
            var menuItem = newMenuItem()
            menuItem.icon = plasmoid.configuration.timer_repeats ? 'media-playlist-repeat' : 'gtk-stop'
            menuItem.text = i18n("Repeat")
            menuItem.clicked.connect(function() {
                timerRepeatsButton.clicked()
            })
            contextMenu.addMenuItem(menuItem)

            // Sound
            var menuItem = newMenuItem()
            menuItem.icon = plasmoid.configuration.timer_sfx_enabled ? 'audio-volume-high' : 'gtk-stop'
            menuItem.text = i18n("Sound")
            menuItem.clicked.connect(function() {
                timerSfxEnabledButton.clicked()
            })
            contextMenu.addMenuItem(menuItem)

            //
            contextMenu.addMenuItem(newSeperator())

            // Set Timer
            var menuItem = newMenuItem()
            menuItem.icon = 'text-field'
            menuItem.text = i18n("Set Timer")
            menuItem.clicked.connect(function() {
                timerView.setTimerViewVisible = true
            })
            contextMenu.addMenuItem(menuItem)

            //
            contextMenu.addMenuItem(newSeperator())

            for (var i = 0; i < defaultTimers.length; i++) {
                var timerSeconds = defaultTimers[i].seconds

                var menuItem = newMenuItem()
                menuItem.icon = 'chronometer'
                menuItem.text = defaultTimers[i].label
                menuItem.clicked.connect(timerView.setDurationAndStart.bind(timerView, defaultTimers[i].seconds))
                contextMenu.addMenuItem(menuItem)
            }

        }

        function show(x, y) {
            loadDynamicActions()
            open(x, y)
        }

        function showBelow(item) {
            visualParent = item
            placement = PlasmaCore.Types.BottomPosedLeftAlignedPopup
            loadDynamicActions()
            openRelative()
        }
    }
}
