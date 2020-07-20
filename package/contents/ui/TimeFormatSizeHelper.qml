import QtQuick 2.4
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: timeFormatSizeHelper
	visible: false

	property Text timeLabel

	FontMetrics {
		id: fontMetrics

		font.pointSize: -1
		font.pixelSize: timeLabel.font.pixelSize
		font.family: timeLabel.font.family
		font.weight: timeLabel.font.weight
		font.italic: timeLabel.font.italic
	}

	function getWidestNumber(fontMetrics) {
		// find widest character between 0 and 9
		var maximumWidthNumber = 0
		var maximumAdvanceWidth = 0
		for (var i = 0; i <= 9; i++) {
			var advanceWidth = fontMetrics.advanceWidth(i)
			if (advanceWidth > maximumAdvanceWidth) {
				maximumAdvanceWidth = advanceWidth
				maximumWidthNumber = i
			}
		}
		// console.log('getWidestNumber', maximumWidthNumber)
		return maximumWidthNumber
	}

	readonly property string widestTimeFormat: {
		var maximumWidthNumber = getWidestNumber(fontMetrics)
		// replace all placeholders with the widest number (two digits)
		var format = timeLabel.timeFormat.replace(/(h+|m+|s+)/g, "" + maximumWidthNumber + maximumWidthNumber) // make sure maximumWidthNumber is formatted as string
		return format
	}

	readonly property real minWidth: formattedSizeHelper.paintedWidth
	function updateMinWidth() {
		var now = new Date(timeModel.currentTime)
		var date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 1, 0, 0)
		var timeAm = Qt.formatDateTime(date, widestTimeFormat)
		var advanceWidthAm = fontMetrics.advanceWidth(timeAm)
		date.setHours(13)
		var timePm = Qt.formatDateTime(date, widestTimeFormat)
		var advanceWidthPm = fontMetrics.advanceWidth(timePm)

		if (advanceWidthAm > advanceWidthPm) {
			formattedSizeHelper.text = timeAm
		} else {
			formattedSizeHelper.text = timePm
		}
		// console.log('updateMinWidth', minWidth)
		// console.log('\t', 'timeAm', timeAm, advanceWidthAm)
		// console.log('\t', 'timePm', timePm, advanceWidthPm)
	}

	PlasmaComponents3.Label {
		id: formattedSizeHelper

		font.pointSize: -1
		font.pixelSize: timeLabel.font.pixelSize
		font.family: timeLabel.font.family
		font.weight: timeLabel.font.weight
		font.italic: timeLabel.font.italic
		wrapMode: timeLabel.wrapMode
		fontSizeMode: Text.FixedSize
	}

	Connections {
		target: clock
		onWidthChanged: timeFormatSizeHelper.updateMinWidth()
		onHeightChanged: timeFormatSizeHelper.updateMinWidth()
	}
	Connections {
		target: timeLabel
		onHeightChanged: timeFormatSizeHelper.updateMinWidth()
		onTimeFormatChanged: timeFormatSizeHelper.updateMinWidth()
	}
	Connections {
		target: timeModel
		onDateChanged: timeFormatSizeHelper.updateMinWidth()
	}
}
