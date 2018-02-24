import QtQuick 2.4
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
	id: timeFromatSizeHelper
	visible: false

	property Text timeLabel
	readonly property string widestTimeFormat: {
		var maximumWidthNumber = getWidestNumber(fontMetrics)
		// replace all placeholders with the widest number (two digits)
		var format = timeLabel.timeFormat.replace(/(h+|m+|s+)/g, "" + maximumWidthNumber + maximumWidthNumber) // make sure maximumWidthNumber is formatted as string
		return format
	}

	font.family: timeLabel.font.family
	font.weight: timeLabel.font.weight
	font.italic: timeLabel.font.italic
	wrapMode: timeLabel.wrapMode

	fontSizeMode: Text.VerticalFit //timeLabel.fontSizeMode
	// font.pointSize: -1
	font.pixelSize: 1024
	height: timeLabel.height

	FontMetrics {
		id: fontMetrics

		font.pixelSize: timeLabel.fontInfo.pixelSize
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
	function getFixedWidth(fontMetrics, widestTimeFormat) {
		
	}

	// property real advanceWidthAm: 0
	// property real advanceWidthPm: 0
	readonly property real minWidth: paintedWidth
	function updateMinWidth() {
		var now = new Date(timeModel.currentTime)
		var date = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 1, 0, 0)
		var timeAm = Qt.formatDateTime(date, widestTimeFormat)
		var advanceWidthAm = fontMetrics.advanceWidth(timeAm)
		// timeFromatSizeHelper.text = timeAm
		// var advanceWidthAm = timeFromatSizeHelper.paintedWidth
		date.setHours(13)
		var timePm = Qt.formatDateTime(date, widestTimeFormat)
		var advanceWidthPm = fontMetrics.advanceWidth(timePm)
		// timeFromatSizeHelper.text = timePm
		// var advanceWidthPm = timeFromatSizeHelper.paintedWidth

		// set the sizehelper's text to the widest time string
		if (advanceWidthAm > advanceWidthPm) {
			timeFromatSizeHelper.text = timeAm
		} else {
			timeFromatSizeHelper.text = timePm
		}
		// console.log('updateMinWidth', widestTimeFormat, advanceWidthAm, advanceWidthPm, paintedWidth, implicitWidth)
		// console.log('\ttimeAm', timeAm, 'timePm', timePm)
	}

	Connections {
		target: clock
		onWidthChanged: timeFromatSizeHelper.updateMinWidth()
		onHeightChanged: timeFromatSizeHelper.updateMinWidth()
	}
	Connections {
		target: timeLabel
		onHeightChanged: timeFromatSizeHelper.updateMinWidth()
		onTimeFormatChanged: timeFromatSizeHelper.updateMinWidth()
	}
	Connections {
		target: timeModel
		onDateChanged: timeFromatSizeHelper.updateMinWidth()
	}
}
