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
		enabled: plasmoid.configuration.widget_show_agenda
		checked: plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = true
	}
	GridLayout {
		columns: 3

		//--- Row1
		ConfigDimension {
			orientation: Qt.Horizontal
			Layout.column: 1
			Layout.row: 0
		}

		ConfigDimension {
			orientation: Qt.Horizontal
			Layout.column: 2
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			orientation: Qt.Vertical
			Layout.column: 0
			Layout.row: 1
		}

		//--- Row3
		ConfigDimension {
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

			implicitWidth: 300
			implicitHeight: 300

			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

	//---
	RadioButton {
		text: i18n("Agenda above the month (Single Column)")
		exclusiveGroup: layoutGroup
		enabled: plasmoid.configuration.widget_show_agenda
		checked: !plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = false
	}

	GridLayout {
		columns: 3

		//--- Row1
		Item {
			implicitWidth: 200
			Layout.column: 0
			Layout.row: 0
		}
		ConfigDimension {
			orientation: Qt.Horizontal
			Layout.column: 1
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			orientation: Qt.Vertical
			Layout.column: 2
			Layout.row: 1
		}

		//--- Row3
		Item {
			implicitHeight: 200
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

			implicitWidth: 300
			implicitHeight: 300

			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}
}
