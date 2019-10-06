import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

GridLayout {
	id: dateTimeSelector
	property var dateTime: new Date()
	property bool enabled: true
	property bool showTime: true
	property string dateFormat: "d MMM, yyyy"
	property string timeFormat: "HH:mm AP"
	property bool dateFirst: true
	columns: 2
	columnSpacing: units.smallSpacing
	readonly property int minimumWidth: dateSelector.implicitWidth + columnSpacing + timeSelector.implicitWidth

	signal dateTimeShifted(date oldDateTime, int deltaDateTime, date newDateTime)
	onDateTimeShifted: {
		dateTimeSelector.dateTime = newDateTime
	}

	// DateSelector {
	// 	id: dateSelector
	// 	// dateFormat: dateTimeSelector.dateFormat
	// 	dateTime: dateTimeSelector.dateTime
	// 	onDateTimeShifted: {
	// 		dateTimeSelector.dateTimeShifted(oldDateTime, deltaDateTime, dateSelector.dateTime)
	// 	}
	PlasmaComponents3.TextField {
		id: dateSelector
		text: Qt.formatDateTime(dateTimeSelector.dateTime, dateTimeSelector.dateFormat)

		enabled: dateTimeSelector.enabled
		// opacity: 1 // Override disabled opacity effect.
		Layout.column: dateTimeSelector.dateFirst ? 0 : 1

		property int defaultMinimumWidth: 80 * units.devicePixelRatio
		readonly property int implicitContentWidth: contentWidth + leftPadding + rightPadding
		implicitWidth: Math.max(defaultMinimumWidth, implicitContentWidth)
	}

	TimeSelector {
		id: timeSelector
		enabled: dateTimeSelector.enabled && dateTimeSelector.showTime
		// opacity: 1 // Override disabled opacity effect.
		visible: dateTimeSelector.showTime
		Layout.column: dateTimeSelector.dateFirst ? 1 : 0

		dateTime: dateTimeSelector.dateTime

		onDateTimeShifted: {
			dateTimeSelector.dateTimeShifted(oldDateTime, deltaDateTime, newDateTime)
		}
	}


}
