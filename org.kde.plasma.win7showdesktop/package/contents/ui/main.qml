/*
    Copyright (C) 2014 Ashish Madeti <ashishmadeti@gmail.com>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/

import QtQuick 2.1
import QtQuick.Layouts 1.1
import QtQuick.Controls.Styles 1.1 as QtQuickControlStyle
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtQuick.Controls.Styles.Plasma 2.0 as Styles

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.showdesktop 0.1

import org.kde.kquickcontrolsaddons 2.0

Item {
    id: root

    property bool vertical: (plasmoid.formFactor == PlasmaCore.Types.Vertical)

    Layout.maximumWidth: 3 // + 5 = 8

    Layout.minimumWidth: Layout.maximumWidth
    Layout.minimumHeight: Layout.maximumHeight

    Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
    Plasmoid.onActivated: showdesktop.showDesktop();

    ShowDesktop {
        id: showdesktop
    }

    Rectangle {
        y: -4
        x: 0
        width: plasmoid.width+5
        height: plasmoid.height+3+5
        color: "transparent"

        Item {
            anchors.fill: parent

            Rectangle {
                id: surfaceNormal
                anchors.fill: parent
                anchors.topMargin: 1
                color: "transparent"
                border.color: theme.buttonBackgroundColor
            }

            Rectangle {
                id: surfaceHovered
                anchors.fill: parent
                anchors.topMargin: 1
                color: theme.buttonBackgroundColor
                opacity: 0
            }

            Rectangle {
                id: surfacePressed
                anchors.fill: parent
                color: theme.buttonHoverColor
                opacity: 0
            }

            state: {
                if (control.containsPress) return "pressed"
                if (control.containsMouse) return "hovered"
                return "normal"
            }

            states: [
                State { name: "normal" },
                State { name: "hovered"
                    PropertyChanges {
                        target: surfaceHovered
                        opacity: 1
                    }
                },
                State { name: "pressed"
                    PropertyChanges {
                        target: surfacePressed
                        opacity: 1
                    }
                }
            ]
    
            transitions: [
                Transition {
                    to: "normal"
                    //Cross fade from pressed to normal
                    ParallelAnimation {
                        NumberAnimation { target: surfaceHovered; property: "opacity"; to: 0; duration: 100 }
                        NumberAnimation { target: surfacePressed; property: "opacity"; to: 0; duration: 100 }
                    }
                }
            ]

            MouseArea {
                id: control
                anchors.fill: parent
                hoverEnabled: true
                onClicked: showdesktop.showDesktop();


                // org.kde.plasma.volume
                property int wheelDelta: 0

                // http://dev.man-online.org/man1/xdotool/
                // xmodmap -pke
                // keycode 122 = XF86AudioLowerVolume NoSymbol XF86AudioLowerVolume
                // keycode 123 = XF86AudioRaiseVolume NoSymbol XF86AudioRaiseVolume
                onWheel: {
                    var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                    wheelDelta += delta;
                    // Magic number 120 for common "one click"
                    // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                    while (wheelDelta >= 120) {
                        wheelDelta -= 120;
                        root.exec(plasmoid.configuration.mousewheel_up)
                    }
                    while (wheelDelta <= -120) {
                        wheelDelta += 120;
                        root.exec(plasmoid.configuration.mousewheel_down)
                    }
                }
            }
        }

        // PlasmaComponents.Button {
        //     anchors.fill: parent
        //     // anchors.left: parent.left
        //     // anchors.top: parent.top + 3
        //     // anchors.right: parent.right + 5
        //     // anchors.bottom: parent.bottom + 5
        //     // width: parent.width
        //     // height: parent.height
        //     onClicked: showdesktop.showDesktop()
        // }
    }

    // PlasmaCore.ToolTipArea {
    //     anchors.fill: parent
    //     mainText : i18n("Show Desktop")
    //     subText : i18n("Show the Plasma desktop")
    //     icon : plasmoid.configuration.icon
    // }

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
}
