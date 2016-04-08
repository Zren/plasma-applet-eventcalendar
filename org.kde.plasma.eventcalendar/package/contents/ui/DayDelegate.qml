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
import org.kde.plasma.calendar 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as Components

import org.kde.plasma.calendar 2.0

import "shared.js" as Shared

MouseArea {
    id: dayStyle

    hoverEnabled: true

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
        label.font.pixelSize = Math.max(theme.smallestFont.pixelSize, Math.floor(daysCalendar.cellHeight / 3))
    }

    Rectangle {
        id: todayRect
        anchors.fill: parent
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
    }

    Rectangle {
        id: highlightDate
        anchors.fill: todayRect
        opacity: {
            if (selected) {
                0.6
            } else if (dayStyle.containsMouse) {
                0.4
            } else {
                0
            }
        }
        visible: !today
        Behavior on opacity { NumberAnimation { duration: units.shortDuration*2 } }
        color: theme.highlightColor
        z: todayRect.z - 1
    }

    Components.Label {
        id: label
        anchors {
            fill: todayRect
            margins: units.smallSpacing
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: model.label || dayNumber
        opacity: isCurrent ? 1.0 : 0.5
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        fontSizeMode: Text.HorizontalFit
        font.pixelSize: Math.max(theme.smallestFont.pixelSize, Math.floor(daysCalendar.cellHeight / 3))
        // This is to avoid the "Both point size and
        // pixel size set. Using pixel size" warnings
        font.pointSize: -1
        color: today ? theme.backgroundColor : theme.textColor
        Behavior on color {
            ColorAnimation { duration: units.shortDuration * 2 }
        }
    }

    Rectangle {
        id: eventBadge
        visible: model.showEventBadge || false
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: parent.height / 5
        opacity: 0.6
        color: theme.highlightColor
    }

    PlasmaCore.ToolTipArea {
        active: model.showEventBadge || false
        anchors.fill: parent
        mainText: Qt.formatDate(thisDate, Locale.LongFormat)
        
        subText: {
            var lines = [];
            for (var i = 0; i < model.events.count; i++) {
                var eventItem = model.events.get(i);
                lines.push('<b>' + eventItem.summary + ':</b> ' + Shared.formatEventDuration(eventItem));
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
