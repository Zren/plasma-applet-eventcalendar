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

    width: timeLabel.width
    Layout.minimumWidth: timeLabel.width
    Layout.maximumWidth: Layout.minimumWidth


    property string timeFormat: "h:mm AP"
    property date currentTime

    property string lastDate: ""

    MouseArea {
        id: mouseArea

        anchors.fill: parent

        onClicked: plasmoid.expanded = !plasmoid.expanded
    }

    Components.Label {
        id: timeLabel

        font.family: theme.defaultFont.family
        font.pointSize: 1024
        minimumPointSize: 1

        width: parent.width
        height: parent.height

        // fontSizeMode: Text.Fit
        fontSizeMode: Text.VerticalFit


        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        text: {
            // clock.currentTime = ;
            return Qt.formatTime(dataSource.data["Local"]["DateTime"], clock.timeFormat);
        }
    }

    // Component.onCompleted: {
    //     clock.minimumWidth = timeLabel.width;
    //     clock.maximumWidth = clock.minimumWidth;
    // }
}
