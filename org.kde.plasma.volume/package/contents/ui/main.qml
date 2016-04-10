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

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon

Item {
    id: main
    Layout.minimumHeight: 400
    Layout.minimumWidth: 400
    Layout.preferredHeight: 400
    Layout.preferredWidth: 400
    property string displayName: i18n("Audio Volume")

    Plasmoid.icon: sinkModel.sinks.length > 0 ? Icon.name(sinkModel.sinks[0].volume, sinkModel.sinks[0].muted) : Icon.name(0, true)
    Plasmoid.switchWidth: units.gridUnit * 12
    Plasmoid.switchHeight: units.gridUnit * 12
    Plasmoid.toolTipMainText: displayName
    // FIXME:    Plasmoid.toolTipSubText: sinkModel.volumeText

    // property alias sinkModel: mixer.sinkModel
    // MixerView {
    //     id: mixer
    // }

    function runOnAllSinks(func) {
        if (typeof(sinkModel) === "undefined") {
            print("This case we need to handle.");
            return;
        } else if (sinkModel.count < 0) {
            return;
        }
        for (var i = 0; i < mixer.sinkModel.count; ++i) {
            sinkModel.currentIndex = i;
            sinkModel.currentItem[func]();
        }
    }

    function increaseVolume() {
        runOnAllSinks("increaseVolume");
    }

    function decreaseVolume() {
        runOnAllSinks("decreaseVolume");
    }

    function muteVolume() {
        runOnAllSinks("toggleMute");
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: plasmoid.icon
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
                    muteVolume();
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
                    increaseVolume();
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    decreaseVolume();
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
            onTriggered: increaseVolume()
        }
        GlobalAction {
            objectName: "decrease_volume"
            text: i18n("Decrease Volume")
            shortcut: Qt.Key_VolumeDown
            onTriggered: decreaseVolume()
        }
        GlobalAction {
            objectName: "mute"
            text: i18n("Mute")
            shortcut: Qt.Key_VolumeMute
            onTriggered: muteVolume()
        }
    }

    VolumeOSD {
        id: osd
    }

    // id: root
    // Layout.minimumHeight: units.gridUnit * 12
    // Layout.minimumWidth: 200
    // Layout.preferredHeight: units.gridUnit * 24
    // Layout.preferredWidth: 400
    // property string displayName: i18n("Audio Volume")

    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50

    // property alias appsModel: appsModel
    // property alias sourceModel: sourceModel
    // property alias sinkModel: sinkModel

    // width: 450
    height: Layout.preferredHeight

    onWidthChanged: {
        Layout.minimumWidth = width
        Layout.preferredWidth = width
    }


    Rectangle {
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }


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

    RowLayout {
        id: mixerItemRow
        anchors.right: parent.right
        // anchors.fill: parent
        height: parent.height
        spacing: 10
        onWidthChanged: {
            // parent.width = width

            console.log(parent.width, width)
        
            // parent.width = Math.max(width, parent.width)
            Layout.minimumWidth = Math.max(width, Layout.minimumWidth)
            Layout.preferredWidth = Math.max(width, Layout.preferredWidth)

            console.log(parent.width)
        }

        MixerItemGroup {
            height: parent.height
            title: 'Apps'
    
            model: appsModel
            delegate: MixerItem {
                width: root.mixerItemWidth
                volumeSliderWidth: root.volumeSliderWidth
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
                width: root.mixerItemWidth
                volumeSliderWidth: root.volumeSliderWidth
                icon: Volume > 0 ? 'mic-on' : 'mic-off'
            }
        }

        MixerItemGroup {
            height: parent.height
            title: 'Speakers'
    
            model: sinkModel
            mixerItemIcon: 'speaker'
        }
    }
    
}