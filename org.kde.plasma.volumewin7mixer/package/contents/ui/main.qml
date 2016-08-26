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

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

import org.kde.plasma.private.volume 0.1

import "../code/icon.js" as Icon
import "../code/sinkcommands.js" as PulseObjectCommands

Item {
    id: main
    // Layout.minimumHeight: units.gridUnit * 12
    Layout.preferredHeight: units.gridUnit * 24 + (mediaControllerArea.visible ? mediaControllerArea.height : 0)
    Layout.minimumWidth: 10
    Layout.preferredWidth: mixerItemRow.width
    Layout.maximumWidth: plasmoid.screenGeometry.width
    property int maxVolumePercent: Plasmoid.configuration.maximumVolume
    property int maxVolumeValue: Math.round(maxVolumePercent * PulseAudio.NormalVolume / 100.0)
    property int volumeStep: Math.round(Plasmoid.configuration.volumeStep * PulseAudio.NormalVolume / 100.0)
    property QtObject draggedStream: null

    property string displayName: i18n("Audio Volume")
    Plasmoid.icon: sinkModel.defaultSink ? Icon.name(sinkModel.defaultSink.volume, sinkModel.defaultSink.muted) : Icon.name(0, true)
    // Plasmoid.switchWidth: units.gridUnit * 12
    // Plasmoid.switchHeight: units.gridUnit * 12
    Plasmoid.toolTipMainText: displayName
    Plasmoid.toolTipSubText: {
        if (sinkModel.defaultSink) {
            var sinkVolumePercent = Math.round(PulseObjectCommands.volumePercent(sinkModel.defaultSink.volume));
            return i18n("Volume at %1%\n%2", sinkVolumePercent, sinkModel.defaultSink.description);
        } else {
            return "";
        }
    }

    function showOsd(volume) {
        osd.show(PulseObjectCommands.volumePercent(volume));
    }

    function increaseDefaultSinkVolume() {
        if (!sinkModel.defaultSink) {
            return;
        }
        sinkModel.defaultSink.muted = false;
        var volume = PulseObjectCommands.increaseVolume(sinkModel.defaultSink);
        showOsd(volume);
    }

    function decreaseDefaultSinkVolume() {
        if (!sinkModel.defaultSink) {
            return;
        }
        sinkModel.defaultSink.muted = false;
        var volume = PulseObjectCommands.decreaseVolume(sinkModel.defaultSink);
        showOsd(volume);
    }

    function toggleDefaultSinksMute() {
        if (!sinkModel.defaultSink) {
            return;
        }
        var toMute = PulseObjectCommands.toggleMute(sinkModel.defaultSink);
        showOsd(toMute ? 0 : sinkModel.defaultSink.volume);
    }

    function showMicrophoneOsd(volume) {
        osd.showMicrophone(PulseObjectCommands.volumePercent(volume));
    }

    function increaseDefaultSourceVolume() {
        console.log
        if (!sourceModel.defaultSource) {
            return;
        }
        sourceModel.defaultSource.muted = false;
        var volume = PulseObjectCommands.increaseVolume(sourceModel.defaultSource);
        showMicrophoneOsd(volume);
    }
    
    function decreaseDefaultSourceVolume() {
        if (!sourceModel.defaultSource) {
            return;
        }
        sourceModel.defaultSource.muted = false;
        var volume = PulseObjectCommands.decreaseVolume(sourceModel.defaultSource);
        showMicrophoneOsd(volume);
    }

    function toggleDefaultSourceMute() {
        if (!sourceModel.defaultSource) {
            return;
        }
        var toMute = PulseObjectCommands.toggleMute(sourceModel.defaultSource);
        showOsd(toMute ? 0 : sourceModel.defaultSource.volume);
    }

    Plasmoid.compactRepresentation: PlasmaCore.IconItem {
        source: sinkModel.defaultSink ? Icon.name(sinkModel.defaultSink.volume, sinkModel.defaultSink.muted) : Icon.name(0, true)
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
                if (delta > 0) {
                    increaseDefaultSinkVolume();
                } else if (delta < 0) {
                    decreaseDefaultSinkVolume();
                }
                return;
                
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
        GlobalAction {
            objectName: "increase_microphone_volume"
            text: i18n("Increase Microphone Volume")
            shortcut: Qt.Key_MicVolumeUp
            onTriggered: increaseDefaultSourceVolume()
        }
        GlobalAction {
            objectName: "decrease_microphone_volume"
            text: i18n("Decrease Microphone Volume")
            shortcut: Qt.Key_MicVolumeDown
            onTriggered: decreaseDefaultSourceVolume()
        }
        GlobalAction {
            objectName: "mic_mute"
            text: i18n("Mute Microphone")
            shortcut: Qt.Key_MicMute
            onTriggered: toggleDefaultSourceMute()
        }
    }

    // org.kde.plasma.mediacontrollercompact
    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            //we get new data when the process finished, so we can remove it
            disconnectSource(sourceName)
        }
    }
    function exec(cmd) {
        //Note: we assume that 'cmd' is executed quickly so that a previous call
        //with the same 'cmd' has already finished (otherwise no new cmd will be
        //added because it is already in the list)
        executeSource.connectSource(cmd)
    }

    VolumeOSD {
        id: osd
    }


    Mpris2DataSource {
        id: mpris2Source
    }

    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50

    // https://github.com/KDE/plasma-pa/tree/master/src/kcm/package/contents/ui
    PulseObjectFilterModel {
        id: appsModel
        sourceModel: SinkInputModel {}
    }
    PulseObjectFilterModel {
        id: appOutputsModel
        sourceModel: SourceOutputModel {}
    }
    SourceModel {
        id: sourceModel
    }
    SinkModel {
        id: sinkModel
    }

    Column {
        anchors.fill: parent

        

    Row {
        id: mixerItemRow
        anchors.right: parent.right
        width: childrenRect.width
        height: parent.height - (mediaControllerArea.visible ? mediaControllerArea.height : 0)
        spacing: 10

        MixerItemGroup {
            height: parent.height
            title: 'Recording Apps'

            model: appOutputsModel
            mixerGroupType: 'SourceOutput'
        }

        MixerItemGroup {
            height: parent.height
            title: 'Apps'

            model: appsModel
            mixerGroupType: 'SinkInput'
        }

        MixerItemGroup {
            height: parent.height
            title: 'Mics'
    
            model: sourceModel
            mixerGroupType: 'Source'
        }

        MixerItemGroup {
            height: parent.height
            title: 'Speakers'
            
            model: sinkModel
            mixerGroupType: 'Sink'
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

        Item {
            id: mediaControllerArea
            visible: mpris2Source.hasPlayer
            width: main.Layout.preferredWidth
            height: 56 // = 48 + 8

            MediaController {
                id: mediaController
                anchors.fill: parent
            }
        }
    }

    PlasmaComponents.ToolButton {
        anchors.right: parent.right
        width: Math.round(units.gridUnit * 1.25)
        height: width
        checkable: true
        iconSource: "window-pin"
        onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
    }

    // function updateActions() {
    //     if (plasmoid.configuration.showOpenKcmAudioVolume) {
    //         plasmoid.setAction("KCMAudioVolume", i18n("Audio Volume Settings..."), "configure");
    //     } else {
    //         plasmoid.removeAction("KCMAudioVolume")
    //     }
    //     if (plasmoid.configuration.showOpenPavucontrol) {
    //         plasmoid.setAction("pavucontrol", i18n("PulseAudio Control"), "configure");
    //     } else {
    //         plasmoid.removeAction("pavucontrol")
    //     }
    // }
    // 
    // Connections {
    //     target: plasmoid
    //     onContextualActionsAboutToShow: {
    //         updateActions()
    //     }
    // }

    function action_alsamixer() {
        exec("konsole -e alsamixer");
    }

    function action_pavucontrol() {
        exec("pavucontrol");
    }

    function action_KCMAudioVolume() {
        KCMShell.open("kcm_pulseaudio");
    }

    Component.onCompleted: {
        plasmoid.setAction("KCMAudioVolume", i18n("Audio Volume Settings..."), "configure");
        plasmoid.setAction("pavucontrol", i18n("PulseAudio Control"), "configure");
        plasmoid.setAction("alsamixer", i18n("AlsaMixer"), "configure");
    }
}