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
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import QtQuick 2.2
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: clock

	property int horizontalFixedLineWidth: 300 * units.devicePixelRatio
	property int verticalFixedLineHeight: 24 * units.devicePixelRatio

	property int targetHeight: verticalFixedLineHeight

	property int horizontalHeight: {
		if (cfg_clockMaxHeight) {
			return cfg_clockMaxHeight
		} else {
			if (cfg_clockline2) {
				// DigitalClock default
				var timeHeight = clock.height * 0.56
				var dateHeight = timeHeight * 0.8
				return timeHeight + dateHeight
			} else {
				// DigitalClock default
				var timeHeight = clock.height * 0.71
				return timeHeight
			}
		}
	}

	property int verticalHeight: {
		if (cfg_clockMaxHeight) {
			return cfg_clockMaxHeight
		} else {
			if (cfg_clockline2) {
				var timeHeight = verticalFixedLineHeight
				var dateHeight = timeHeight * 0.8
				return timeHeight + dateHeight
			} else {
				var timeHeight = verticalFixedLineHeight
				return timeHeight
			}
		}
	}

	property date currentTime: new Date()

	property string clockFontFamily: plasmoid.configuration.clockFontFamily || theme.defaultFont.family
	property string cfg_clockTimeFormat: plasmoid.configuration.clockTimeFormat
	property string cfg_clockTimeFormat2: plasmoid.configuration.clockTimeFormat2
	property bool cfg_clockline2: plasmoid.configuration.clockline2
	property double cfg_clockLine2HeightRatio: plasmoid.configuration.clockLine2HeightRatio
	property bool cfg_clockLine1Bold: plasmoid.configuration.clockLine1Bold
	property bool cfg_clockLine2Bold: plasmoid.configuration.clockLine2Bold
	property int cfg_clockMaxHeight: plasmoid.configuration.clockMaxHeight
	property bool cfg_clock_fixedWidth: true // plasmoid.configuration.clock_fixedWidth

	// property int lineWidth: cfg_clockline2 ? Math.max(timeLabel.paintedWidth, timeLabel2.paintedWidth) : timeLabel.paintedWidth
	property int lineHeight2: targetHeight * cfg_clockLine2HeightRatio
	property int lineHeight1: cfg_clockline2 ? targetHeight - lineHeight2 : targetHeight

	Column {
		id: labels
		spacing: 0
		anchors.centerIn: parent

		Item {
			id: timeContainer1

			PlasmaComponents3.Label {
				id: timeLabel1
				anchors.centerIn: parent

				font.family: clock.clockFontFamily
				font.weight: clock.cfg_clockLine1Bold ? Font.Bold : Font.Normal
				font.pointSize: -1
				font.pixelSize: timeContainer1.height
				minimumPixelSize: 1

				fontSizeMode: Text.FixedSize
				wrapMode: Text.NoWrap

				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				smooth: true

				// onWidthChanged: console.log('timeLabel1.width', width)
				// onPaintedWidthChanged: console.log('timeLabel1.paintedWidth', paintedWidth)

				property string timeFormat: {
					if (clock.cfg_clockTimeFormat) {
						return clock.cfg_clockTimeFormat
					} else {
						return Qt.locale().timeFormat(Locale.ShortFormat)
					}
				}
				text: Qt.formatDateTime(clock.currentTime, timeFormat)
			}

			// Debugging
			// Rectangle { border.color: "#ff0"; anchors.fill: parent; border.width: 1; color: "transparent"; visible: plasmoid.configuration.debugging }
			// Rectangle { border.color: "#f00"; anchors.fill: timeLabel1; border.width: 1; color: "transparent"; visible: plasmoid.configuration.debugging }
		}
		Item {
			id: timeContainer2
			visible: cfg_clockline2

			PlasmaComponents3.Label {
				id: timeLabel2
				anchors.centerIn: parent
				font.family: clock.clockFontFamily
				font.weight: clock.cfg_clockLine2Bold ? Font.Bold : Font.Normal
				font.pointSize: -1
				font.pixelSize: timeContainer2.height
				minimumPixelSize: 1

				fontSizeMode: Text.FixedSize
				wrapMode: Text.NoWrap

				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				smooth: true

				property string timeFormat: {
					if (clock.cfg_clockTimeFormat2) {
						return clock.cfg_clockTimeFormat2
					} else {
						return Qt.locale().dateFormat(Locale.ShortFormat)
					}
				}
				text: Qt.formatDateTime(clock.currentTime, timeFormat)
			}

			// Debugging
			// Rectangle { border.color: "#ff0"; anchors.fill: parent; border.width: 1; color: "transparent"; visible: plasmoid.configuration.debugging }
			// Rectangle { border.color: "#f00"; anchors.fill: timeLabel2; border.width: 1; color: "transparent"; visible: plasmoid.configuration.debugging }
		}
	}

	readonly property real fixedWidth: cfg_clockline2 ? Math.max(timeFormatSizer1.minWidth, timeFormatSizer2.minWidth) : timeFormatSizer1.minWidth
	// onFixedWidthChanged: console.log('fixedWidth', cfg_clockline2, timeFormatSizer1.minWidth, timeFormatSizer2.minWidth)
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

			PropertyChanges { target: clock
				targetHeight: clock.horizontalHeight
				width: clock.fixedWidth
				Layout.minimumWidth: clock.fixedWidth
				Layout.preferredWidth: clock.fixedWidth
			}
			PropertyChanges { target: timeContainer1
				width: clock.fixedWidth
				height: clock.lineHeight1
			}
			PropertyChanges { target: timeContainer2
				width: clock.fixedWidth
				height: clock.lineHeight2
			}
		},

		State {
			name: "verticalPanel"
			when: plasmoid.formFactor == PlasmaCore.Types.Vertical

			PropertyChanges { target: clock
				targetHeight: clock.verticalHeight
				Layout.minimumHeight: clock.targetHeight
				Layout.preferredHeight: clock.targetHeight
			}
			PropertyChanges { target: timeContainer1
				width: clock.width
				height: clock.lineHeight1
			}
			PropertyChanges { target: timeContainer2
				width: clock.width
				height: clock.lineHeight2
			}
			PropertyChanges { target: timeLabel1
				width: timeContainer1.width
				fontSizeMode: Text.HorizontalFit
			}
			PropertyChanges { target: timeLabel2
				width: timeContainer2.width
				fontSizeMode: Text.HorizontalFit
			}
		},

		State {
			name: "floating"
			when: plasmoid.formFactor == PlasmaCore.Types.Planar

			PropertyChanges { target: clock
				targetHeight: clock.verticalFixedLineHeight
				width: clock.horizontalFixedLineWidth
				Layout.preferredWidth: clock.horizontalFixedLineWidth
				height: clock.targetHeight
				Layout.preferredHeight: clock.targetHeight
			}
			PropertyChanges { target: timeContainer1
				width: clock.width
				height: clock.lineHeight1
			}
			PropertyChanges { target: timeContainer2
				width: clock.width
				height: clock.lineHeight2
			}
			PropertyChanges { target: timeLabel1
				width: timeContainer1.width
				fontSizeMode: Text.HorizontalFit
			}
			PropertyChanges { target: timeLabel2
				width: timeContainer2.width
				fontSizeMode: Text.HorizontalFit
			}
		}
	]
}
