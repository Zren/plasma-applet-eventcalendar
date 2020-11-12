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
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */
import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.calendar 2.0

import "LocaleFuncs.js" as LocaleFuncs

MouseArea {
	id: dayStyle

	hoverEnabled: true
	property string eventBadgeType: "bottomBar"
	property string todayStyle: "theme"
	property real radius: Math.min(width, height) * plasmoid.configuration.monthCellRadius

	signal activated()

	readonly property date thisDate: new Date(yearNumber, typeof monthNumber !== "undefined" ? monthNumber - 1 : 0, typeof dayNumber !== "undefined" ? dayNumber : 1)
	readonly property bool today: {
		var today = root.today
		var result = true
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
				return 0.6
			} else if (today) {
				return 0.4
			} else {
				return 0
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
				return 0.6
			} else if (dayStyle.containsMouse) {
				return 0.4
			} else {
				return 0
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

		Loader {
			id: eventBadgeLoader
			anchors.fill: parent

			active: parent.visible
			property Component badgeComponent: {
				if (dayStyle.eventBadgeType == 'bottomBar') {
					return eventColorsBarBadgeComponent
				} else if (dayStyle.eventBadgeType == 'bottomBarHighlight') {
					return highlightBarBadgeComponent
				} else if (dayStyle.eventBadgeType == 'count') {
					return eventCountBadgeComponent
				} else if (dayStyle.eventBadgeType == 'dots') {
					return dotsBadgeComponent
				} else if (dayStyle.eventBadgeType == 'theme') {
					return themeBadgeComponent
				} else {
					return null
				}
			}
			sourceComponent: badgeComponent

			readonly property var modelEvents: model.events
			readonly property int modelEventsCount: modelEvents ? modelEvents.count : 0
			property alias dayStyle: dayStyle // aka DayDelegate
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
		anchors.fill: parent
		active: root.showTooltips
		visible: root.showTooltips // Needed with active=false to make sure the ToolTipArea doesn't close a parent ToolTipArea. Eg: DateSelector.
		mainText: containsMouse ? Qt.formatDate(thisDate, Qt.locale().dateFormat(Locale.LongFormat)) : ""
		subText: containsMouse ? tooltipBody() : ""
		function tooltipBody() {
			if (!model.events) {
				return ''
			}
			var lines = []
			for (var i = 0; i < model.events.count; i++) {
				var eventItem = model.events.get(i)
				var line = ''
				line += '<font color="' + eventItem.backgroundColor + '">■</font> '
				line += '<b>' + eventItem.summary + ':</b> '
				line += LocaleFuncs.formatEventDuration(eventItem, {
					relativeDate: thisDate,
					clock24h: appletConfig.clock24h,
				})
				lines.push(line)
			}
			return lines.join('<br>')
		}
	}

	Component.onCompleted: {
		if (stack.depth === 1 && today) {
			root.date = model
		}
	}
}
