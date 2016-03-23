/*
 * Copyright 2013 Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2013 Martin Klapetek <mklapetek@kde.org>
 * Copyright 2014 David Edmundson <davidedmundson@kde.org>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of
 * the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

Item {
    id: clock

    width: labels.width
    Layout.minimumWidth: labels.width
    Layout.maximumWidth: labels.width

    // property string timeFormat: "h:mm AP"
    property bool cfg_clock_24h: false
    property variant timerView: null
    
    // Testing with qmlview
    Rectangle {
        visible: !root
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: plasmoid.expanded = !plasmoid.expanded
    }

    Row {
        id: labels
        spacing: 10

        Components.Label {
            id: timerLabel
            visible: timerView && timerView.timerSeconds > 0

            font.family: theme.defaultFont.family
            font.pointSize: 1024
            minimumPointSize: 1

            width: timerLabel.paintedWidth
            height: sizehelper.height

            // fontSizeMode: Text.Fit
            fontSizeMode: Text.VerticalFit
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter


            // anchors.horizontalCenter: clock.horizontalCenter

            text: {
                return timerView ? "T" + timerView.timerSeconds : "0:00"
            }
        }

        PlasmaCore.IconItem {
            source: "chronometer"
            width: sizehelper.height
            height: sizehelper.height
            visible: timerView
        }

        Components.Label {
            id: timeLabel

            font.family: theme.defaultFont.family
            font.pointSize: 1024
            minimumPointSize: 1

            width: timeLabel.paintedWidth
            height: sizehelper.height

            // fontSizeMode: Text.Fit
            fontSizeMode: Text.VerticalFit
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter


            // anchors.horizontalCenter: clock.horizontalCenter

            text: {
                return Qt.formatTime(dataSource.data["Local"]["DateTime"], clock.cfg_clock_24h ? "h:mm" : "h:mm AP");
            }
        }
    }
    

    // Component.onCompleted: {
    //     clock.minimumWidth = timeLabel.width;
    //     clock.maximumWidth = clock.minimumWidth;
    // }

    Components.Label {
        id: sizehelper

        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
        font.pixelSize: 1024
        font.pointSize: 1024
        verticalAlignment: Text.AlignVCenter
        visible: false
        height: parent.height
        width: sizehelper.paintedWidth
        fontSizeMode: Text.VerticalFit
    }
}
