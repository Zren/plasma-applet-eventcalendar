import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

import "../code/sinkcommands.js" as PulseObjectCommands

Item {
    id: mixerItem
    width: 50
    height: parent.height

    property string icon: ''
    property int volumeSliderWidth: 50

    // property string label: {
    //     var desc = PulseObject.description;
    //     var map = {
    //         'Built-In Audio Analog Stereo': 'Speakers',
    //     }
    //     if (map[desc]) {
    //         return map[desc];
    //     } else if (desc.indexOf('HDMI'))
    //     desk
    // }
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
    
    ColumnLayout {
        anchors.fill: parent

        QIconItem {
            id: clientIcon
            icon: mixerItem.icon
            // visible: false
            anchors.horizontalCenter: parent.horizontalCenter
            width: mixerItem.volumeSliderWidth
            height: mixerItem.volumeSliderWidth
        }

        Label {
            id: textLabel
            text: mixerItem.label
            color: PlasmaCore.ColorScope.textColor
            opacity: 0.6
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
        }

        PlasmaCore.ToolTipArea {
            anchors.top: clientIcon.top
            anchors.bottom: textLabel.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            mainText: mixerItem.label
            subText: {
                var lines = [];
                lines.push(PulseObject.name);
                lines.push(PulseObject.description);
                lines.push(PulseObject.activePortIndex)
                for (var key in PulseObject.properties) {
                    lines.push('<b>' + key + ':</b> ' + PulseObject.properties[key]);
                }
                
                return lines.join('<br>');
            }
            icon: mixerItem.icon
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
                maximumValue: 65536
                stepSize: maximumValue / 100
                visible: PulseObject.hasVolume
                enabled: {
                    if (typeof PulseObject.volumeWritable === 'undefined') {
                        return !PulseObject.muted
                    }
                    return PulseObject.volumeWritable && !PulseObject.muted
                }

                onVolumeChanged: {
                    ignoreValueChange = true;
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
            }
        }

        Item {
            id: muteButton
        }


        VolumeIcon {
            Layout.maximumWidth: mixerItem.volumeSliderWidth
            Layout.maximumHeight: mixerItem.volumeSliderWidth
            Layout.minimumWidth: Layout.maximumWidth
            Layout.minimumHeight: Layout.maximumHeight

            anchors.horizontalCenter: parent.horizontalCenter

            volume: PulseObject.volume
            muted: PulseObject.muted

            MouseArea {
                anchors.fill: parent
                onPressed: PulseObject.muted = !PulseObject.muted
            }
        }
    }
    
}