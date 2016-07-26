import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.kquickcontrolsaddons 2.0
import org.kde.draganddrop 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

import "../code/sinkcommands.js" as PulseObjectCommands

PlasmaComponents.ListItem {
    id: mixerItem
    width: 50
    height: parent.height
    checked: dropArea.containsDrag
    opacity: main.draggedStream && mixerItemType != 'Sink' ? 0.4 : 1
    separatorVisible: false
    property string mixerItemType: ''
    property int volumeSliderWidth: 50
    property bool isVolumeBoosted: false

    property string icon: {
        if (mixerItemType == 'SinkInput') {
            // App
            var client = PulseObject.client;
            // Virtual streams don't have a valid client object, force a default icon for them
            if (client) {
                if (client.properties['application.icon_name']) {
                    return client.properties['application.icon_name'].toLowerCase();
                } else if (client.properties['application.process.binary']) {
                    var binary = client.properties['application.process.binary'].toLowerCase()
                    // FIXME: I think this should do a reverse-desktop-file lookup
                    // or maybe appdata could be used?
                    // At any rate we need to attempt mapping binary to desktop file
                    // such that we could get the icon.
                    if (binary === 'chrome' || binary === 'chromium') {
                        return 'google-chrome';
                    }
                    return binary;
                }
                return 'unknown';
            } else {
                return 'audio-card';
            }
        } else if (mixerItemType == 'Sink') {
            // Speaker
            return 'speaker';
        } else if (mixerItemType == 'Source') {
            // Microphone
            if (PulseObject.volume > 0 && !PulseObject.muted) {
                return 'mic-on';
            } else {
                return 'mic-off';
            }
        } else {
            return 'unknown';
        }
    }

    property string label: {
        var name = PulseObject.name;
        if (name.indexOf('alsa_input.') >= 0) {
            if (name.indexOf('.analog-') >= 0) {
                return 'Mic'
            }
        } else if (name.indexOf('alsa_output.') >= 0) {
            if (name.indexOf('.analog-') >= 0) {
                return 'Speaker'
            } else if (name.indexOf('.hdmi-') >= 0) {
                return 'HDMI'
            }
        }
        var appName = PulseObject.properties['application.name'];
        if (appName) {
            return appName;
        }

        return name
    }

    property string tooltipSubText: {
        // maximum of 8 visible lines. Extra lines are cut off.
        var lines = [];
        function addLine(key, value) {
            if (typeof value === 'undefined') return;
            if (typeof value === 'string' && value.length === 0) return;
            lines.push('<b>' + key + ':</b> ' + value);
        }
        addLine('Name', PulseObject.name);
        addLine('Description', PulseObject.description);
        addLine('Volume', Math.round(PulseObjectCommands.volumePercent(PulseObject.volume)) + "%");
        if (typeof PulseObject.activePortIndex !== 'undefined') {
            addLine('Port', '[' + PulseObject.activePortIndex +'] ' + PulseObject.ports[PulseObject.activePortIndex].description);
        }
        if (typeof PulseObject.deviceIndex !== 'undefined') {
            var isDefaultSink = false;
            if (mixerItemType == 'SinkInput') {
                isDefaultSink = PulseObject.deviceIndex === sinkModel.defaultSink.index;
            }
            if (!isDefaultSink) {
                addLine('Device', '[' + PulseObject.deviceIndex + '] ');
            }
        }
        function addPropertyLine(key) {
            addLine(key, PulseObject.properties[key]);
        }
        addPropertyLine('alsa.mixer_name');
        addPropertyLine('application.process.binary');
        addPropertyLine('application.process.id');
        addPropertyLine('application.process.user');

        // for (var key in PulseObject.properties) {
        //     lines.push('<b>' + key + ':</b> ' + PulseObject.properties[key]);
        // }
        return lines.join('<br>');
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        enabled: mixerItemType == 'Sink'
        onDrop: {
            console.log('DropArea.onDrop')
            console.log(main.draggedStream, '=>', PulseObject)
            // logObj(main.draggedStream)
            // logObj(main.draggedStream.properties)
            // logObj(PulseObject)
            // logObj(PulseObject.properties)
            main.draggedStream.deviceIndex = PulseObject.index
        }
    }

    function logObj(obj) {
        for (var key in obj) {
            if (typeof obj[key] === 'function') continue;
            console.log(obj, key, obj[key])
        }
    }

    DragArea {
        id: dragArea
        anchors.fill: parent
        delegate: parent
        enabled: mixerItemType == 'SinkInput'

        mimeData {
            source: mixerItem
        }

        onDragStarted: {
            console.log('DragArea.onDragStarted')
            main.draggedStream = PulseObject
        }
        onDrop: {
            console.log('DragArea.onDrop')
            main.draggedStream = null
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: dragArea.enabled ? (pressed ? Qt.ClosedHandCursor : Qt.OpenHandCursor) : undefined
        }
    }
    
    ColumnLayout {
        anchors.fill: parent

        QIconItem {
            id: clientIcon
            icon: mixerItem.icon
            // visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            width: mixerItem.volumeSliderWidth
            height: mixerItem.volumeSliderWidth

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: mixerItem.label
                subText: tooltipSubText
                icon: mixerItem.icon
            }
        }
    
        Label {
            id: textLabel
            text: mixerItem.label + '\n'
            function updateLineCount() {
                if (lineCount == 1) {
                    textLabel.text = mixerItem.label + '\n'
                } else if (truncated) {
                    textLabel.text = mixerItem.label
                }
            }
            onLineCountChanged: updateLineCount()
            onTruncatedChanged: updateLineCount()

            color: PlasmaCore.ColorScope.textColor
            opacity: 0.6
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 2
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter

            PlasmaCore.ToolTipArea {
                anchors.fill: parent
                mainText: mixerItem.label
                subText: tooltipSubText
                icon: mixerItem.icon
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            VolumeSlider {
                id: slider
                orientation: Qt.Vertical
                height: parent.height
                width: mixerItem.volumeSliderWidth
                anchors.horizontalCenter: parent.horizontalCenter

                // Helper properties to allow async slider updates.
                // While we are sliding we must not react to value updates
                // as otherwise we can easily end up in a loop where value
                // changes trigger volume changes trigger value changes.
                property int volume: PulseObject.volume
                property bool ignoreValueChange: false

                Layout.fillWidth: true

                minimumValue: 0
                // FIXME: I do wonder if exposing max through the model would be useful at all
                maximumValue: mixerItem.isVolumeBoosted ? 98304 : 65536
                stepSize: maximumValue / 100
                visible: PulseObject.hasVolume
                enabled: typeof PulseObject.volumeWritable === 'undefined' || PulseObject.volumeWritable

                opacity: {
                    return enabled && PulseObject.muted ? 0.5 : 1
                }

                onVolumeChanged: {
                    ignoreValueChange = true;
                    if (!mixerItem.isVolumeBoosted && PulseObject.volume > maximumValue) {
                        mixerItem.isVolumeBoosted = true;
                    }
                    value = PulseObject.volume;
                    ignoreValueChange = false;
                }

                onValueChanged: {
                    if (!ignoreValueChange) {
                        PulseObjectCommands.setVolume(PulseObject, value);

                        if (!pressed) {
                            updateTimer.restart();
                        }
                    }
                }

                onPressedChanged: {
                    if (!pressed) {
                        // Make sure to sync the volume once the button was
                        // released.
                        // Otherwise it might be that the slider is at v10
                        // whereas PA rejected the volume change and is
                        // still at v15 (e.g.).
                        updateTimer.restart();
                    }
                }

                Timer {
                    id: updateTimer
                    interval: 200
                    onTriggered: slider.value = PulseObject.volume
                }

                // Block wheel events
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    // onWheel: wheel.accepted = true
                }

                Component.onCompleted: {
                    mixerItem.isVolumeBoosted = PulseObject.volume > 66000 // 100% is 65863.68, not 65536... Bleh. Just trigger at a round number.
                }
            }
        }

        Item {
            id: muteButton
        }

        PlasmaComponents.ToolButton {
            Layout.maximumWidth: mixerItem.volumeSliderWidth
            Layout.maximumHeight: mixerItem.volumeSliderWidth
            Layout.minimumWidth: Layout.maximumWidth
            Layout.minimumHeight: Layout.maximumHeight
            anchors.horizontalCenter: parent.horizontalCenter

            VolumeIcon {
                anchors.fill: parent
                
                volume: PulseObject.volume
                muted: PulseObject.muted
            }
            
            onClicked: {
                onPressed: PulseObject.muted = !PulseObject.muted
            }
        }
    }
    
    // https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmacomponents/qmenu.cpp
    // Example: https://github.com/KDE/plasma-desktop/blob/master/applets/taskmanager/package/contents/ui/ContextMenu.qml
    PlasmaComponents.ContextMenu {
        id: contextMenu

        function newSeperator() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu);
        }
        function newMenuItem() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu);
        }

        function loadDynamicActions() {
            contextMenu.clearMenuItems();

            // Mute
            var menuItem = newMenuItem();
            menuItem.text = i18n("Mute");
            menuItem.checkable = true;
            menuItem.checked = i === PulseObject.activePortIndex;
            menuItem.checked = PulseObject.muted;
            menuItem.clicked.connect(function() {
                PulseObject.muted = !PulseObject.muted
            });
            contextMenu.addMenuItem(menuItem);

            // Volume Boost
            var menuItem = newMenuItem();
            menuItem.text = i18n("Volume Boost (150% Volume)");
            menuItem.checkable = true;
            menuItem.checked = mixerItem.isVolumeBoosted
            menuItem.clicked.connect(function() {
                mixerItem.isVolumeBoosted = !mixerItem.isVolumeBoosted
            });
            contextMenu.addMenuItem(menuItem);

            // Default
            if (typeof PulseObject.default === "boolean") {
                var menuItem = newMenuItem();
                menuItem.text = i18n("Default");
                menuItem.checkable = true;
                menuItem.checked = PulseObject.default
                menuItem.clicked.connect(function() {
                    PulseObject.default = true
                });
                contextMenu.addMenuItem(menuItem);
            }

            // Ports
            if (PulseObject.ports && PulseObject.ports.length > 1) {
                contextMenu.addMenuItem(newSeperator());
                for (var i = 0; i < PulseObject.ports.length; i++) {
                    var port = PulseObject.ports[i];
                    var menuItem = newMenuItem();
                    menuItem.text = '[' + i + '] ' + port.description;
                    menuItem.checkable = true;
                    menuItem.checked = i === PulseObject.activePortIndex;
                    var setActivePort = function(portIndex){
                        return function() {
                            PulseObject.activePortIndex = portIndex;
                        };
                    };
                    menuItem.clicked.connect(setActivePort(i));
                    contextMenu.addMenuItem(menuItem);
                }
            }
        }

        function show(x, y) {
            loadDynamicActions();
            open(x, y);
        }
    }

    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent

        onClicked: contextMenu.show(mouse.x, mouse.y);
    }
}