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
    // Layout.maximumWidth: timeLabel.width

    property date currentTime: {
        if (typeof dataSource === 'undefined') {
            return new Date();
        } else {
            return dataSource.data["Local"]["DateTime"];
        }
    }

    property string cfg_clock_timeformat: "h:mm AP"
    property string cfg_clock_timeformat_2: "yyyy-MM-dd"
    property bool cfg_clock_24h: false
    property bool cfg_clock_line_2: false
    property int lineWidth: cfg_clock_line_2 ? Math.max(timeLabel.paintedWidth, timeLabel2.paintedWidth) : timeLabel.paintedWidth
    property int lineHeight: cfg_clock_line_2 ? sizehelper.height / 2 : sizehelper.height
    
    
    // Testing with qmlview
    Rectangle {
        visible: typeof root === 'undefined'
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }

    Row {
        id: labels
        spacing: 10

        Components.Label {
            id: timerLabel
            visible: false

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
                return "0:00"
            }
        }

        PlasmaCore.IconItem {
            source: "chronometer"
            width: sizehelper.height
            height: sizehelper.height
            visible: false
        }

        Column {
            // width: Math.max(timeLabel.width, timeLabel2.width)
            // height: sizehelper.height

            Components.Label {
                id: timeLabel

                font.family: theme.defaultFont.family
                font.pointSize: 1024
                minimumPointSize: 1

                width: clock.lineWidth
                height: clock.lineHeight

                // fontSizeMode: Text.Fit
                fontSizeMode: Text.VerticalFit
                wrapMode: Text.NoWrap

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter


                // anchors.horizontalCenter: clock.horizontalCenter

                text: {
                    if (clock.cfg_clock_timeformat) {
                        return Qt.formatDateTime(clock.currentTime, clock.cfg_clock_timeformat);
                    } else {
                        return Qt.formatTime(clock.currentTime, clock.cfg_clock_24h ? "hh:mm" : "h:mm AP");
                    }
                }
            }
            Components.Label {
                id: timeLabel2

                font.family: theme.defaultFont.family
                font.pointSize: 1024
                minimumPointSize: 1

                width: clock.lineWidth
                height: clock.lineHeight

                // fontSizeMode: Text.Fit
                fontSizeMode: Text.VerticalFit
                wrapMode: Text.NoWrap

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter


                // anchors.horizontalCenter: clock.horizontalCenter

                text: {
                    if (clock.cfg_clock_timeformat_2) {
                        return Qt.formatDateTime(clock.currentTime, clock.cfg_clock_timeformat_2);
                    } else {
                        return Qt.formatDate(clock.currentTime, "yyyy-MM-dd");
                    }
                }
            }
        }
        
    }
    

    Component.onCompleted: {

    }

    // Timer {
    //     interval: 1000
    //     running: true
    //     repeat: true

    //     onTriggered: {
    //         clock.width = timeLabel.width
    //         clock.height = labels.height
    //     }
    // }

    Components.Label {
        id: sizehelper

        font.weight: timeLabel.font.weight
        font.italic: timeLabel.font.italic
        // font.pixelSize: 1024
        font.pointSize: 1024
        verticalAlignment: Text.AlignVCenter
        visible: false
        height: parent.height
        width: sizehelper.paintedWidth
        fontSizeMode: Text.VerticalFit
    }
}
