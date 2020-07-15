import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore

GridLayout {
	id: dateTimeSelector
	property var dateTime: new Date()
	property bool enabled: true
	property bool showTime: true
	property alias dateFormat: dateSelector.dateFormat
	property alias timeFormat: timeSelector.timeFormat
	property bool dateFirst: true
	columns: 2
	columnSpacing: units.smallSpacing
	readonly property int minimumWidth: dateSelector.implicitWidth + columnSpacing + timeSelector.implicitWidth

	signal dateTimeShifted(date oldDateTime, int deltaDateTime, date newDateTime)
	onDateTimeShifted: {
		dateTimeSelector.dateTime = newDateTime
	}

	DateSelector {
		id: dateSelector
		enabled: dateTimeSelector.enabled
		// opacity: 1 // Override disabled opacity effect.
		Layout.column: dateTimeSelector.dateFirst ? 0 : 1

		dateTime: dateTimeSelector.dateTime
		dateFormat: i18nc("event editor date format", "d MMM, yyyy")

		onDateTimeShifted: {
			dateTimeSelector.dateTimeShifted(oldDateTime, deltaDateTime, newDateTime)
		}
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
