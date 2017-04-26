/*
 * Copyright 2013 Heena Mahour <heena393@gmail.com>
 * Copyright 2013 Sebastian Kügler <sebas@kde.org>
 * Copyright 2015 Kai Uwe Broulik <kde@privat.broulik.de>
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
import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

import org.kde.plasma.calendar 2.0

import "shared.js" as Shared

MouseArea {
    id: dayStyle

    hoverEnabled: true
    property string eventBadgeType: "bottomBar"
    property string todayStyle: "theme"
    property real radius: Math.min(width, height) * plasmoid.configuration.month_cell_radius

    signal activated

    readonly property date thisDate: new Date(yearNumber, typeof monthNumber !== "undefined" ? monthNumber - 1 : 0, typeof dayNumber !== "undefined" ? dayNumber : 1)
    readonly property bool today: {
        var today = root.today;
        var result = true;
        if (dateMatchingPrecision >= Calendar.MatchYear) {
            result = result && today.getFullYear() === thisDate.getFullYear()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
            result = result && today.getMonth() === thisDate.getMonth()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
            result = result && today.getDate() === thisDate.getDate()
        }
        return result
    }
    readonly property bool selected: {
        var current = root.currentDate
        var result = true
        if (dateMatchingPrecision >= Calendar.MatchYear) {
            result = result && current.getFullYear() === thisDate.getFullYear()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearAndMonth) {
            result = result && current.getMonth() === thisDate.getMonth()
        }
        if (dateMatchingPrecision >= Calendar.MatchYearMonthAndDay) {
            result = result && current.getDate() === thisDate.getDate()
        }
        return result
    }

    onHeightChanged: {
        // this is needed here as the text is first rendered, counting with the default root.cellHeight
        // then root.cellHeight actually changes to whatever it should be, but the Label does not pick
        // it up after that, so we need to change it explicitly after the cell size changes
        // label.font.pixelSize = Math.max(theme.smallestFont.pixelSize, Math.floor(daysCalendar.cellHeight / 3))
    }

    Rectangle {
        id: todayRect
        anchors.fill: parent
        // anchors.centerIn: parent
        // width: Math.min(parent.width, parent.height)
        // height: width
        // radius: width / 2
        visible: todayStyle == "theme"
        opacity: {
            if (selected && today) {
                0.6
            } else if (today) {
                0.4
            } else {
                0
            }
        }
        Behavior on opacity { NumberAnimation { duration: units.shortDuration*2 } }
        color: theme.textColor
        radius: dayStyle.radius
    }

    Rectangle {
        id: highlightDate
        anchors.fill: parent
        // anchors.centerIn: parent
        // width: Math.min(parent.width, parent.height)
        // height: width
        // radius: width / 2
        opacity: {
            if (selected) {
                0.6
            } else if (dayStyle.containsMouse) {
                0.4
            } else {
                0
            }
        }
        // visible: !today
        Behavior on opacity { NumberAnimation { duration: units.shortDuration*2 } }
        color: theme.highlightColor
        radius: dayStyle.radius
        z: todayRect.z - 1
    }


    property int eventCount: model.events ? model.events.count : 0
    property var eventColors: []
    property bool useHightlightColor: eventColors.length === 0

    onEventCountChanged: updateEventColors()
    function updateEventColors() {
        var set = {}
        for (var i = 0; i < eventCount; i++) {
            var eventItem = model.events.get(i)
            if (eventItem.backgroundColor) {
                set[eventItem.backgroundColor] = true
            }
        }
        eventColors = Object.keys(set)
    }


    Item {
        id: eventBadge
        visible: model.showEventBadge || false
        anchors.fill: parent

        Rectangle {
            id: eventBadgeBottomBarHighlight
            visible: parent.visible && (dayStyle.eventBadgeType == 'bottomBarHighlight' || (dayStyle.eventBadgeType == 'bottomBar' && dayStyle.useHightlightColor))
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height / 8
            opacity: 0.6
            color: theme.highlightColor
        }

        Item {
            id: eventBadgeBottomBar
            visible: parent.visible && dayStyle.eventBadgeType == 'bottomBar'
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height / 8
            
            property bool usePadding: !plasmoid.configuration.month_show_border
            anchors.leftMargin: usePadding ? parent.width/8 : 0
            anchors.rightMargin: usePadding ? parent.width/8 : 0
            anchors.bottomMargin: usePadding ? parent.height/16 : 0

            RowLayout {
                anchors.fill: parent
                spacing: 0

                Repeater {
                    model: dayStyle.eventColors

                    Rectangle {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        color: modelData

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: 1
                            border.color: theme.backgroundColor
                            opacity: 0.5
                        }
                    }
                    
                }
            }
        }

        Item {
            id: eventBadgeDots
            visible: parent.visible && dayStyle.eventBadgeType == 'dots'
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.margins: parent.height / 4
            property int dotSize: (parent.height / 8) + dotBorderWidth*2
            property color dotColor: theme.highlightColor
            property int dotBorderWidth: plasmoid.configuration.show_outlines ? 1 : 0
            property color dotBorderColor: theme.backgroundColor

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: units.smallSpacing

                Rectangle {
                    visible: parent.visible && model.events.count >= 1
                    width: eventBadgeDots.dotSize
                    height: eventBadgeDots.dotSize
                    radius: width / 2
                    color: eventBadgeDots.dotColor
                    border.width: eventBadgeDots.dotBorderWidth
                    border.color: eventBadgeDots.dotBorderColor
                }
                Rectangle {
                    visible: parent.visible && model.events.count >= 2
                    width: eventBadgeDots.dotSize
                    height: eventBadgeDots.dotSize
                    radius: width / 2
                    color: eventBadgeDots.dotColor
                    border.width: eventBadgeDots.dotBorderWidth
                    border.color: eventBadgeDots.dotBorderColor
                }
                Rectangle {
                    visible: parent.visible && model.events.count >= 3
                    width: eventBadgeDots.dotSize
                    height: eventBadgeDots.dotSize
                    radius: width / 2
                    color: eventBadgeDots.dotColor
                    border.width: eventBadgeDots.dotBorderWidth
                    border.color: eventBadgeDots.dotBorderColor
                }
            }
        }

        Rectangle {
            id: eventBadgeCount
            visible: parent.visible && dayStyle.eventBadgeType == 'count'
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: parent.height / 3
            width: eventBadgeCountText.width
            color: {
                if (plasmoid.configuration.show_outlines) {
                    var c = Qt.darker(theme.backgroundColor, 1); // Cast to color
                    c.a = 0.6; // 60%
                    return c;
                } else {
                    return "transparent";
                }
            }

            Components.Label {
                id: eventBadgeCountText
                height: parent.height
                width: Math.max(paintedWidth, height)
                anchors.centerIn: parent

                color: theme.highlightColor
                text: parent.visible ? model.events.count : 0
                font.weight: Font.Bold
                font.pointSize: 1024
                fontSizeMode: Text.VerticalFit
                wrapMode: Text.NoWrap

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                smooth: true
            }
        }

        Loader {
            id: eventBadgeTheme
            active: parent.visible && dayStyle.eventBadgeType == 'theme'
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            height: parent.height / 3
            width: height
            sourceComponent: eventsMarkerComponent
        }
    }

    Text {
        id: label
        anchors {
            fill: parent
            margins: units.smallSpacing
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: model.label || dayNumber
        opacity: isCurrent ? 1.0 : 0.5
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        fontSizeMode: Text.HorizontalFit
        font.pixelSize: {
            if (today && todayStyle == "bigNumber") {
                return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 2), Math.floor(dayStyle.width * 7/8)))
            } else {
                return Math.max(theme.smallestFont.pixelSize, Math.min(Math.floor(dayStyle.height / 3), Math.floor(dayStyle.width * 5/8)))
            }
        }
        // This is to avoid the "Both point size and
        // pixel size set. Using pixel size" warnings
        font.pointSize: -1
        color: {
            if (today) {
                if (todayStyle == "bigNumber") {
                    if (dayStyle.containsMouse || dayStyle.selected) {
                        return theme.textColor
                    } else {
                        return theme.highlightColor
                    }
                } else { // todayStyle == "theme"
                    return theme.backgroundColor
                }
            } else {
                return theme.textColor
            }
        }
        Behavior on color {
            ColorAnimation { duration: units.shortDuration * 2 }
        }
    }

    PlasmaCore.ToolTipArea {
        // active: model.showEventBadge || false
        anchors.fill: parent
        mainText: Qt.formatDate(thisDate, Locale.LongFormat)
        
        subText: {
            if (!model.events) {
                return '';
            }
            var lines = [];
            for (var i = 0; i < model.events.count; i++) {
                var eventItem = model.events.get(i);
                var line = '';
                line += '<font color="' + eventItem.backgroundColor + '">■</font> ';
                line += '<b>' + eventItem.summary + ':</b> ';
                line += Shared.formatEventDuration(eventItem, {
                    relativeDate: thisDate,
                    clock_24h: plasmoid && plasmoid.configuration && plasmoid.configuration.clock_24h,
                });
                lines.push(line);
            }
            return lines.join('<br>');
        }
    }

    Component.onCompleted: {
        if (stack.depth === 1 && today) {
            root.date = model
        }
    }
}
