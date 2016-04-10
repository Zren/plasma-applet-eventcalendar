/*
    Copyright 2014-2015 Harald Sitter <sitter@kde.org>

    This program is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License as
    published by the Free Software Foundation; either version 2 of
    the License or (at your option) version 3 or any later version
    accepted by the membership of KDE e.V. (or its successor approved
    by the membership of KDE e.V.), which shall act as a proxy
    defined in Section 14 of version 3 of the license.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon

Item {
    id: main
    // Layout.minimumHeight: units.gridUnit * 12
    Layout.preferredHeight: units.gridUnit * 24
    Layout.minimumWidth: 10
    Layout.preferredWidth: mixerItemRow.width
    Layout.maximumWidth: plasmoid.screenGeometry.width

    property string displayName: i18n("Audio Volume")

    // Plasmoid.icon: sinkModel.sinks.length > 0 ? Icon.name(sinkModel.sinks[0].volume, sinkModel.sinks[0].muted) : Icon.name(0, true)
    // Plasmoid.switchWidth: units.gridUnit * 12
    // Plasmoid.switchHeight: units.gridUnit * 12
    Plasmoid.toolTipMainText: displayName

    property int maximumValue: 65536

    function bound(value, min, max) {
        return Math.max(min, Math.min(value, max));
    }

    function volumePercent(volume) {
        return 100 * volume / maximumValue;
    }

    function toggleMute(pulseObject) {
        var toMute = !pulseObject.muted;
        if (toMute) {
            osd.show(0);
        } else {
            osd.show(volumePercent(pulseObject.volume));
        }
        pulseObject.muted = toMute;
    }

    function setVolume(pulseObject, volume) {
        if (volume > 0 && pulseObject.muted) {
            toggleMute(pulseObject);
        }
        pulseObject.volume = volume
    }

    function addVolume(pulseObject, step) {
        console.log('addVolume', pulseObject, step);
        var volume = bound(pulseObject.volume + step, 0, maximumValue);
        setVolume(pulseObject, volume);
        osd.show(volumePercent(volume));
    }

    function increaseVolume(pulseObject) {
        console.log('increaseVolume', pulseObject);
        var step = maximumValue / 15;
        addVolume(pulseObject, step);
    }


    function decreaseVolume(pulseObject) {
        console.log('decreaseVolume', pulseObject);
        var step = maximumValue / 15;
        addVolume(pulseObject, -step);
    }

    function increaseDefaultSinkVolume() {
        console.log('increaseDefaultSinkVolume');
        for (var i = 0; i < sinkModel.sinks.length; ++i) {
            increaseVolume(sinkModel.sinks[i]);
        }
    }

    function decreaseDefaultSinkVolume() {
        console.log('decreaseDefaultSinkVolume');
        for (var i = 0; i < sinkModel.sinks.length; ++i) {
            decreaseVolume(sinkModel.sinks[i]);
        }
    }

    function toggleDefaultSinksMute() {
        console.log('toggleDefaultSinksMute');
        for (var i = 0; i < sinkModel.sinks.length; ++i) {
            toggleMute(sinkModel.sinks[i]);
        }
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: sinkModel.sinks.length > 0 ? Icon.name(sinkModel.sinks[0].volume, sinkModel.sinks[0].muted) : Icon.name(0, true)
        active: mouseArea.containsMouse
        colorGroup: PlasmaCore.ColorScope.colorGroup

        MouseArea {
            id: mouseArea

            property int wheelDelta: 0
            property bool wasExpanded: false

            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
            onPressed: {
                if (mouse.button == Qt.LeftButton) {
                    wasExpanded = plasmoid.expanded;
                } else if (mouse.button == Qt.MiddleButton) {
                    toggleDefaultSinksMute();
                }
            }
            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    plasmoid.expanded = !wasExpanded;
                }
            }
            onWheel: {
                var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                wheelDelta += delta;
                // Magic number 120 for common "one click"
                // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    increaseDefaultSinkVolume();
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    decreaseDefaultSinkVolume();
                }
            }
        }
    }

    GlobalActionCollection {
        // KGlobalAccel cannot transition from kmix to something else, so if
        // the user had a custom shortcut set for kmix those would get lost.
        // To avoid this we hijack kmix name and actions. Entirely mental but
        // best we can do to not cause annoyance for the user.
        // The display name actually is updated to whatever registered last
        // though, so as far as user visible strings go we should be fine.
        // As of 2015-07-21:
        //   componentName: kmix
        //   actions: increase_volume, decrease_volume, mute
        name: "kmix"
        displayName: main.displayName
        GlobalAction {
            objectName: "increase_volume"
            text: i18n("Increase Volume")
            shortcut: Qt.Key_VolumeUp
            onTriggered: increaseDefaultSinkVolume()
        }
        GlobalAction {
            objectName: "decrease_volume"
            text: i18n("Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseDefaultSinkVolume()
        }
        GlobalAction {
            objectName: "mute"
            text: i18n("Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: toggleDefaultSinksMute()
        }
    }

    VolumeOSD {
        id: osd
    }

    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50

    // https://github.com/KDE/plasma-pa/tree/master/src/kcm/package/contents/ui
    PulseObjectFilterModel {
        id: appsModel
        sourceModel: SinkInputModel {}
    }
    SourceModel {
        id: sourceModel
    }
    SinkModel {
        id: sinkModel
    }

    Row {
        id: mixerItemRow
        anchors.right: parent.right
        width: childrenRect.width
        height: parent.height
        spacing: 10

        MixerItemGroup {
            height: parent.height
            title: 'Apps'
    
            model: appsModel
            delegate: MixerItem {
                width: main.mixerItemWidth
                volumeSliderWidth: main.volumeSliderWidth
                icon: {
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
                }

            }
        }

        MixerItemGroup {
            height: parent.height
            title: 'Mics'
    
            model: sourceModel
            delegate: MixerItem {
                width: main.mixerItemWidth
                volumeSliderWidth: main.volumeSliderWidth
                icon: PulseObject.volume > 0 && !PulseObject.muted ? 'mic-on' : 'mic-off'
            }
        }

        MixerItemGroup {
            height: parent.height
            title: 'Speakers'
    
            model: sinkModel
            mixerItemIcon: 'speaker'
        }

        // GroupBox {
        //     style: PlasmaStyles.GroupBoxStyle {}

        //     Text {
        //         text: parent.title
        //         color: PlasmaCore.ColorScope.textColor
        //         Layout.fillWidth: true
        //         horizontalAlignment: Text.AlignHCenter
        //     }
            
        //     ListView {
        //         model: sinkModel
        //         width: Math.max(childrenRect.width, mixerItemWidth)
        //         // width: childrenRect.width
        //         height: parent.height
        //         spacing: 10
        //         boundsBehavior: Flickable.StopAtBounds
        //         orientation: ListView.Horizontal

        //         delegate: MixerItem {
        //             width: mixerItemWidth
        //             volumeSliderWidth: volumeSliderWidth
        //             icon: 'speaker'
        //         }
        //     }
        // }

    }
    
}