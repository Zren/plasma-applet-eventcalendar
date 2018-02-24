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
    // Layout.maximumWidth: timeLabel1.width
    property int verticalLineHeight: cfg_clock_maxheight > 0 ? cfg_clock_maxheight : 24
    property int verticalDoubleLineHeight: cfg_clock_maxheight > 0 ? cfg_clock_maxheight : 24*2

    property date currentTime: new Date()

    property string clock_fontfamily: plasmoid.configuration.clock_fontfamily || theme.defaultFont.family
    property string cfg_clock_timeformat: plasmoid.configuration.clock_timeformat
    property string cfg_clock_timeformat_2: plasmoid.configuration.clock_timeformat_2
    property bool cfg_clock_line_2: plasmoid.configuration.clock_line_2
    property double cfg_clock_line_2_height_ratio: plasmoid.configuration.clock_line_2_height_ratio
    property bool cfg_clock_line_1_bold: plasmoid.configuration.clock_line_1_bold
    property bool cfg_clock_line_2_bold: plasmoid.configuration.clock_line_2_bold
    property int cfg_clock_maxheight: plasmoid.configuration.clock_maxheight
    property bool cfg_clock_fixedWidth: true // plasmoid.configuration.clock_fixedWidth

    // property int lineWidth: cfg_clock_line_2 ? Math.max(timeLabel.paintedWidth, timeLabel2.paintedWidth) : timeLabel.paintedWidth
    property int lineHeight1: cfg_clock_line_2 ? sizehelper.height - (sizehelper.height * cfg_clock_line_2_height_ratio) : sizehelper.height
    property int lineHeight2: cfg_clock_line_2 ? sizehelper.height * cfg_clock_line_2_height_ratio : sizehelper.height

    Column {
        id: labels
        spacing: 0
        anchors.centerIn: parent

        Components.Label {
            id: timeLabel1

            font.family: clock.clock_fontfamily
            font.weight: clock.cfg_clock_line_1_bold ? Font.Bold : Font.Normal
            // font.pointSize: -1
            font.pixelSize: 1024
            minimumPixelSize: 1

            fontSizeMode: Text.VerticalFit
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            smooth: true

            // onWidthChanged: console.log('timeLabel1.width', width)
            // onPaintedWidthChanged: console.log('timeLabel1.paintedWidth', paintedWidth)

            property string timeFormat: {
                if (clock.cfg_clock_timeformat) {
                    return clock.cfg_clock_timeformat
                } else {
                    return Qt.locale().timeFormat(Locale.ShortFormat)
                }
            }
            text: Qt.formatDateTime(clock.currentTime, timeFormat)
        }
        Components.Label {
            id: timeLabel2
            visible: cfg_clock_line_2

            font.family: clock.clock_fontfamily
            font.weight: clock.cfg_clock_line_2_bold ? Font.Bold : Font.Normal
            // font.pointSize: -1
            font.pixelSize: 1024
            minimumPixelSize: 1

            fontSizeMode: Text.VerticalFit
            wrapMode: Text.NoWrap

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            smooth: true

            property string timeFormat: {
                if (clock.cfg_clock_timeformat_2) {
                    return clock.cfg_clock_timeformat_2
                } else {
                    return Qt.locale().dateFormat(Locale.ShortFormat)
                }
            }
            text: Qt.formatDateTime(clock.currentTime, timeFormat)
        }
        
    }

    Components.Label {
        id: sizehelper

        font.family: timeLabel1.font.family
        font.weight: timeLabel1.font.weight
        font.italic: timeLabel1.font.italic
        // font.pointSize: -1
        font.pixelSize: 1024
        height: paintedHeight
        visible: false
    }

    readonly property real fixedWidth: cfg_clock_line_2 ? Math.max(timeFormatSizer1.minWidth, timeFormatSizer2.minWidth) : timeFormatSizer1.minWidth
    // onFixedWidthChanged: console.log('fixedWidth', cfg_clock_line_2, timeFormatSizer1.minWidth, timeFormatSizer2.minWidth)
    TimeFormatSizeHelper {
        id: timeFormatSizer1
        timeLabel: timeLabel1
    }
    TimeFormatSizeHelper {
        id: timeFormatSizer2
        timeLabel: timeLabel2
    }

    state: "verticalPanel"
    states: [
        State {
            name: "horizontalPanel"
            when: plasmoid.formFactor == PlasmaCore.Types.Horizontal

            PropertyChanges { target: sizehelper
                width: sizehelper.paintedWidth
                height: cfg_clock_maxheight > 0 ? cfg_clock_maxheight : clock.height
                fontSizeMode: Text.VerticalFit
            }
            PropertyChanges { target: timeLabel1
                // width: clock.lineWidth
                width: clock.fixedWidth
                height: clock.lineHeight1
            }
            PropertyChanges { target: timeLabel2
                // width: clock.lineWidth
                width: clock.fixedWidth
                height: clock.lineHeight2
            }
        },

        State {
            name: "verticalPanel"
            when: plasmoid.formFactor == PlasmaCore.Types.Vertical

            PropertyChanges { target: clock
                height: cfg_clock_line_2 ? verticalDoubleLineHeight : verticalLineHeight
                // Layout.minimumHeight: 1
                // Layout.preferredHeight: clock.height
                // Layout.maximumHeight: clock.height
                // Layout.fillHeight: false
                // Layout.fillWidth: true
                Layout.maximumHeight: cfg_clock_line_2 ? verticalDoubleLineHeight : verticalLineHeight
                Layout.minimumHeight: Layout.maximumHeight
            }

            PropertyChanges { target: sizehelper
                width: clock.width
                height: cfg_clock_line_2 ? verticalDoubleLineHeight : verticalLineHeight
                fontSizeMode: Text.Fit
                // horizontalAlignment: Text.AlignHCenter
            }
            PropertyChanges { target: timeLabel1
                width: clock.width
                height: cfg_clock_line_2 ? verticalDoubleLineHeight - (verticalDoubleLineHeight * cfg_clock_line_2_height_ratio) : verticalLineHeight
                fontSizeMode: Text.Fit
            }
            PropertyChanges { target: timeLabel2
                width: clock.width
                height: cfg_clock_line_2 ? verticalDoubleLineHeight * cfg_clock_line_2_height_ratio : 0
                fontSizeMode: Text.Fit
            }
        },

        State {
            name: "floating"
            when: plasmoid.formFactor == PlasmaCore.Types.Planar

            PropertyChanges { target: sizehelper
                width: 300
                height: 24
                fontSizeMode: Text.Fit
            }
            PropertyChanges { target: timeLabel1
                width: 300
                height: 24
                fontSizeMode: Text.Fit
            }
            PropertyChanges { target: timeLabel2
                width: 300
                height: 24
                fontSizeMode: Text.Fit
            }
        }
    ]
}
