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

    Rectangle {
        id:icon
        // source: plasmoid.configuration.icon
        // active: mouseArea.containsMouse
        color: mouseArea.containsMouse ? theme.buttonHoverColor : theme.buttonBackgroundColor
        // anchors.fill: parent
        y: -3
        x: 0
        width: plasmoid.width+5
        height: plasmoid.height+3+5
    }
    ShowDesktop {
        id: showdesktop
    }

    PlasmaCore.ToolTipArea {
        anchors.fill: parent
        mainText : i18n("Show Desktop")
        subText : i18n("Show the Plasma desktop")
        icon : plasmoid.configuration.icon

        MouseArea {
            id: mouseArea
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
