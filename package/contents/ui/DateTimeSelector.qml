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

	PlasmaComponents3.TextField {
		id: dateSelector
		text: Qt.formatDateTime(dateTimeSelector.dateTime, dateTimeSelector.dateFormat)
		enabled: dateTimeSelector.enabled
		opacity: 1 // Override disabled opacity effect.
		// defaultMinimumWidth: 0
		Layout.column: dateTimeSelector.dateFirst ? 0 : 1

		// property int defaultMinimumWidth: units.gridUnit * 8
		property int defaultMinimumWidth: 0
		readonly property int implicitContentWidth: contentWidth + leftPadding + rightPadding
		implicitWidth: Math.max(defaultMinimumWidth, implicitContentWidth)
	}
	PlasmaComponents3.TextField {
		id: timeSelector
		text: Qt.formatDateTime(dateTimeSelector.dateTime, dateTimeSelector.timeFormat)
		enabled: dateTimeSelector.enabled && dateTimeSelector.showTime
		opacity: 1 // Override disabled opacity effect.
		visible: dateTimeSelector.showTime
		// defaultMinimumWidth: 0
		Layout.column: dateTimeSelector.dateFirst ? 1 : 0

		// property int defaultMinimumWidth: units.gridUnit * 8
		property int defaultMinimumWidth: 0
		readonly property int implicitContentWidth: contentWidth + leftPadding + rightPadding
		implicitWidth: Math.max(defaultMinimumWidth, implicitContentWidth)
	}


}
