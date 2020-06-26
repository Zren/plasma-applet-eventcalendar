import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import ".."
import "../lib"

ConfigPage {
	id: page

	SystemPalette {
		id: syspal
	}

	//---
	ExclusiveGroup { id: layoutGroup }
	RadioButton {
		text: i18n("Agenda to the left (Two Columns)")
		exclusiveGroup: layoutGroup
		checked: plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = true
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
	}
	GridLayout {
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 400 * units.devicePixelRatio
		columns: 3

		//--- Row1
		ConfigDimension {
			suffix: i18n("px")
			orientation: Qt.Horizontal
			Layout.column: 1
			Layout.row: 0
		}

		ConfigDimension {
			suffix: i18n("px")
			orientation: Qt.Horizontal
			Layout.column: 2
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			suffix: i18n("px")
			orientation: Qt.Vertical
			Layout.column: 0
			Layout.row: 1
		}

		//--- Row3
		ConfigDimension {
			suffix: i18n("px")
			orientation: Qt.Vertical
			Layout.column: 0
			Layout.row: 2
		}

		//--- Center
		Rectangle {
			color: "#f00"
			Layout.column: 1
			Layout.row: 1
			Layout.columnSpan: 2
			Layout.rowSpan: 2

			implicitWidth: 300 * units.devicePixelRatio
			implicitHeight: 300 * units.devicePixelRatio

			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

	//---
	Item {
		implicitHeight: units.largeSpacing * 2
	}

	//---
	RadioButton {
		text: i18n("Agenda above the month (Single Column)")
		exclusiveGroup: layoutGroup
		checked: !plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = false
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
	}

	GridLayout {
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 400 * units.devicePixelRatio
		columns: 3

		//--- Row1
		Item {
			implicitWidth: 150 * units.devicePixelRatio
			Layout.fillWidth: true
			Layout.column: 0
			Layout.row: 0
		}
		ConfigDimension {
			suffix: i18n("px")
			orientation: Qt.Horizontal
			Layout.column: 1
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			configKey: 'monthHeightSingleColumn'
			suffix: i18n("px")
			orientation: Qt.Vertical
			Layout.column: 2
			Layout.row: 1
		}

		//--- Row3
		Item {
			implicitHeight: 150 * units.devicePixelRatio
			Layout.column: 2
			Layout.row: 2
		}

		//--- Center
		Rectangle {
			color: "#f00"
			Layout.column: 0
			Layout.row: 1
			Layout.columnSpan: 2
			Layout.rowSpan: 2

			implicitWidth: 300 * units.devicePixelRatio
			implicitHeight: 300 * units.devicePixelRatio

			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
