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

import "../code/icon.js" as Icon
import "../code/sinkcommands.js" as PulseObjectCommands

PlasmaComponents.ListItem {
    id: mixerItem
    width: mixerItemWidth + (showChannels ? numChannels * (channelSliderWidth + volumeSliderRow.spacing) : 0) + background.margins.left + background.margins.right
    height: parent.height
    checked: dropArea.containsDrag
    opacity: !main.draggedStream || dropArea.canBeDroppedOn ? 1 : 0.4
    separatorVisible: false
    property string mixerItemType: ''
    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50
    property int channelSliderWidth: volumeSliderWidth
    property bool isVolumeBoosted: false
    property bool hasChannels: typeof PulseObject.channels !== 'undefined'
    property int numChannels: hasChannels ? PulseObject.channels.length : 0
    property bool showChannels: false

    PlasmaCore.FrameSvgItem {
        id: background
        imagePath: "widgets/listitem"
        prefix: "normal"
        visible: false
    }

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
                    if (binary === 'chrome' || binary === 'chromium' || binary === 'chrome (deleted)') {
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
            var portName = PulseObject.ports[PulseObject.activePortIndex].name;
            if (portName.indexOf('headphones') >= 0) { // Eg: analog-output-headphones
                return 'audio-headphones';
            }
            if (PulseObject.name.indexOf('alsa_output.') >= 0 && PulseObject.name.indexOf('.hdmi-') >= 0) {
                // return Qt.resolvedUrl('../icons/hdmi.svg');
                return 'video-television';
            }
            if (PulseObject.name.indexOf('bluez_sink.') === 0) {
                return 'preferences-system-bluetooth';
            }
            return 'speaker';
        } else if (mixerItemType == 'Source') {
            // Microphone
            return 'mic-on';
        } else if (mixerItemType == 'SourceOutput') {
            // Recording Apps
            return 'mic-on';
        } else {
            return 'unknown';
        }
    }

    property string label: {
        var name = PulseObject.name;
        if (name.indexOf('alsa_input.') >= 0) {
            if (name.indexOf('.analog-') >= 0) {
                return i18n("Mic")
            }
        } else if (name.indexOf('alsa_output.') >= 0) {
            if (name.indexOf('.analog-') >= 0) {
                return i18n("Speaker")
            } else if (name.indexOf('.hdmi-') >= 0) {
                return i18n("HDMI")
            }
        }

        var appName = PulseObject.properties['application.name'];
        if (appName) {
            return appName;
        }

        if (PulseObject.description) {
            return PulseObject.description;
        }

        return name
    }

    property var name
    property bool usingDefaultDevice: {
        if (typeof PulseObject.deviceIndex !== 'undefined') {
            if (mixerItemType == 'SinkInput') {
                return PulseObject.deviceIndex === sinkModel.defaultSink.index
            } else if (mixerItemType == 'SourceOutput') {
                console.log('mixerItemType', mixerItemType, PulseObject.deviceIndex, sourceModel.defaultSource.index)
                return PulseObject.deviceIndex === sourceModel.defaultSource.index
            } else {
                return false
            }
        } else {
            return true // Just pretend it's linked to the default so we don't show that it's not.
        }
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
            if (!usingDefaultDevice) {
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
        property bool canBeDroppedOn: {
            if (main.draggedStream) {
                if (main.draggedStreamType == 'SinkInput') {
                    return mixerItemType == 'Sink'
                } else if (main.draggedStreamType == 'Source') {
                    return mixerItemType == 'SourceOutput'
                }
            }
            return false
        }

        enabled: canBeDroppedOn
        onDrop: {
            console.log('DropArea.onDrop')
            console.log(main.draggedStream, '=>', PulseObject)
            // logPulseObj(main.draggedStream)
            // logPulseObj(PulseObject)
            if (main.draggedStreamType == 'SinkInput') {
                main.draggedStream.deviceIndex = PulseObject.index
            } else if (main.draggedStreamType == 'Source') {
                PulseObject.draggedStream == main.draggedStream.index
            }
        }
    }

    function logObj(obj) {
        for (var key in obj) {
            if (typeof obj[key] === 'function') continue;
            console.log(obj, key, obj[key])
        }
    }

    function logPulseObj(obj) {
        logObj(obj);
        if (typeof obj.ports !== 'undefined') {
            for (var i = 0; i < obj.ports.length; i++) {
                logObj(obj.ports[i]);
            }
        }
        if (typeof obj.properties !== 'undefined') {
            logObj(obj.properties);
        }
        if (typeof obj.client !== 'undefined') {
            logObj(obj.client);
            logObj(obj.client.properties);
        }
    }

    Row {
        id: volumeSliderRow
        // anchors.fill: parent
        height: parent.height
        width: parent.width
        spacing: 10


        ColumnLayout {
            // anchors.fill: parent
            width: mixerItem.mixerItemWidth
            height: parent.height

            PlasmaCore.ToolTipArea {
                id: tooltip
                Layout.fillWidth: true
                Layout.preferredHeight: iconLabelButtonRow.height
                mainText: mixerItem.label
                subText: tooltipSubText
                icon: mixerItem.icon

                DragArea {
                    id: dragArea
                    anchors.fill: parent
                    delegate: iconLabelButton // parent
                    enabled: mixerItemType == 'SinkInput' || mixerItemType == 'Source'

                    mimeData {
                        source: mixerItem
                    }

                    onDragStarted: {
                        console.log('DragArea.onDragStarted')
                        main.startDrag(PulseObject, mixerItemType)
                    }
                    onDrop: {
                        console.log('DragArea.onDrop')
                        main.clearDrag()
                    }

                    PlasmaComponents.ToolButton {
                    // Item {
                        id: iconLabelButton
                        anchors.fill: parent

                        Column {
                            id: iconLabelButtonRow
                            width: parent.width
                            Item {
                                // width: mixerItem.volumeSliderWidth
                                // height: mixerItem.volumeSliderWidth
                                width: parent.width
                                height: mixerItem.volumeSliderWidth

                                PlasmaCore.IconItem {
                                    id: clientIcon
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: mixerItem.volumeSliderWidth
                                    height: parent.height
                                    anchors.fill: parent
                                    source: mixerItem.icon
                                    overlays: mixerItem.usingDefaultDevice ? [] : ['emblem-unlocked']

                                    // From ToolButtonStyle:
                                    active: iconLabelButton.hovered
                                    colorGroup: iconLabelButton.hovered || !iconLabelButton.flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
                                }
                            }

                            Label {
                                id: textLabel
                                Layout.fillWidth: true
                                width: parent.width

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
                                horizontalAlignment: Text.AlignHCenter
                            }
                        }

                        onClicked: contextMenu.showBelow(iconLabelButton)
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                
                // VolumeSlider {
                VerticalVolumeSlider {
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

                PlasmaCore.IconItem {
                    anchors.fill: parent
                    readonly property bool isMic: mixerItemType == 'Source' || mixerItemType == 'SourceOutput'
                    readonly property string prefix: isMic ? 'microphone-sensitivity' : 'audio-volume'
                    source: Icon.name(PulseObject.volume, PulseObject.muted, prefix)

                    // From ToolButtonStyle:
                    active: parent.hovered
                    colorGroup: parent.hovered || !parent.flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
                }
                
                onClicked: {
                    onPressed: {
                        // logPulseObj(PulseObject)
                        PulseObject.muted = !PulseObject.muted
                    }
                }
            }
        }


        Repeater {
            model: showChannels && hasChannels ? PulseObject.channels : 0
            ColumnLayout {
                // anchors.fill: parent
                width: mixerItem.channelSliderWidth
                height: parent.height

                Label {
                    text: PulseObject.channels[index] + '\n'
                    function updateLineCount() {
                        if (lineCount == 1) {
                            text = PulseObject.channels[index] + '\n'
                        } else if (truncated) {
                            text = PulseObject.channels[index]
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
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    VolumeSlider {
                        orientation: Qt.Vertical
                        width: mixerItem.channelSliderWidth
                        height: parent.height
                        enabled: false
                        // anchors.horizontalCenter: parent.horizontalCenter

                        // value: PulseObject.channelVolumes.at(index)
                        minimumValue: 0
                        // FIXME: I do wonder if exposing max through the model would be useful at all
                        maximumValue: 65536

                        Component.onCompleted: {
                            console.log(PulseObject.channels[index], model, index) // Front Left QQmlDMListAccessorData(0x1b33b40) 0
                            console.log('channelVolumes', PulseObject.channelVolumes, typeof PulseObject.channelVolumes) // channelVolumes QVariant(QList<qlonglong>) object
                        }
                    }
                }
                
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
                    if (plasmoid.configuration.moveAllAppsOnSetDefault) {
                        console.log(appsModel, appsModel.count)
                        for (var i = 0; i < appsModel.count; i++) {
                            var stream = appsModel.get(i); 
                            stream = stream.PulseObject;
                            // console.log(i, stream, stream.name, stream.deviceIndex, PulseObject.index)
                            stream.deviceIndex = PulseObject.index;
                        }
                        
                    }
                });
                contextMenu.addMenuItem(menuItem);
            }

            // Channels
            if (mixerItem.hasChannels) {
                var menuItem = newMenuItem();
                menuItem.text = i18n("Show Channels (Not Working)");
                menuItem.checkable = true;
                menuItem.checked = mixerItem.showChannels
                menuItem.clicked.connect(function() {
                    mixerItem.showChannels = !mixerItem.showChannels
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

            // Properties
            contextMenu.addMenuItem(newSeperator());
            var menuItem = newMenuItem();
            menuItem.text = i18n("Properties");
            menuItem.clicked.connect(function() {
                mixerItem.showPropertiesDialog();
                plasmoid.expanded = false;
            });
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

    MouseArea {
        acceptedButtons: Qt.RightButton
        anchors.fill: parent

        onClicked: contextMenu.show(mouse.x, mouse.y);
    }

    function showPropertiesDialog() {
        var qml = 'import QtQuick 2.0; \
        PulseObjectDialog { \
            pulseObject: PulseObject \
        } ';
        var dialog = Qt.createQmlObject(qml, mixerItem);
        dialog.visible = true;
    }
}
