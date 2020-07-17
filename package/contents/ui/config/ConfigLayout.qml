import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.0 as Kirigami
import QtGraphicalEffects 1.0 // Colorize

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
		text: i18n("Calendar to the left of the Agenda (Two Columns)")
		exclusiveGroup: layoutGroup
		checked: plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = true
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
	}
	GridLayout {
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 400 * Kirigami.Units.devicePixelRatio
		columns: 3

		//--- Row1
		ConfigDimension {
			configKey: 'leftColumnWidth'
			suffix: i18n("px")
			orientation: Qt.Horizontal
			lineColor: syspal.text
			Layout.column: 1
			Layout.row: 0
		}

		ConfigDimension {
			configKey: 'rightColumnWidth'
			suffix: i18n("px")
			orientation: Qt.Horizontal
			lineColor: syspal.text
			Layout.column: 2
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			configKey: 'topRowHeight'
			suffix: i18n("px")
			orientation: Qt.Vertical
			lineColor: syspal.text
			Layout.column: 0
			Layout.row: 1
		}

		//--- Row3
		ConfigDimension {
			configKey: 'bottomRowHeight'
			suffix: i18n("px")
			orientation: Qt.Vertical
			lineColor: syspal.text
			Layout.column: 0
			Layout.row: 2
		}

		//--- Center
		Item {
			Layout.column: 1
			Layout.row: 1
			Layout.columnSpan: 2
			Layout.rowSpan: 2

			implicitWidth: 300 * Kirigami.Units.devicePixelRatio
			implicitHeight: 300 * Kirigami.Units.devicePixelRatio

			Layout.fillWidth: true
			Layout.fillHeight: true

			Image {
				id: twoColumnsImage
				anchors.fill: parent
				source: plasmoid.file("", "images/twocolumns.svg")
				smooth: true
				visible: false
			}

			ColorOverlay {
				anchors.fill: parent
				source: twoColumnsImage
				color: syspal.text
				opacity: 0.8
			}
		}
	}

	//---
	Item {
		implicitHeight: Kirigami.Units.largeSpacing * 2
	}

	//---
	RadioButton {
		text: i18n("Agenda below the Calendar (Single Column)")
		exclusiveGroup: layoutGroup
		checked: !plasmoid.configuration.twoColumns
		onClicked: plasmoid.configuration.twoColumns = false
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
	}

	GridLayout {
		Layout.fillWidth: false
		Layout.alignment: Qt.AlignHCenter
		Layout.preferredWidth: 400 * Kirigami.Units.devicePixelRatio
		columns: 3

		//--- Row1
		Item {
			implicitWidth: 150 * Kirigami.Units.devicePixelRatio
			Layout.fillWidth: true
			Layout.column: 0
			Layout.row: 0
		}
		ConfigDimension {
			configKey: 'leftColumnWidth'
			suffix: i18n("px")
			orientation: Qt.Horizontal
			lineColor: syspal.text
			Layout.column: 1
			Layout.row: 0
		}

		//--- Row2
		ConfigDimension {
			configKey: 'monthHeightSingleColumn'
			suffix: i18n("px")
			orientation: Qt.Vertical
			lineColor: syspal.text
			Layout.column: 2
			Layout.row: 1
		}

		//--- Row3
		Item {
			implicitHeight: 150 * Kirigami.Units.devicePixelRatio
			Layout.column: 2
			Layout.row: 2
		}

		//--- Center
		Item {
			Layout.column: 0
			Layout.row: 1
			Layout.columnSpan: 2
			Layout.rowSpan: 2

			implicitWidth: 300 * Kirigami.Units.devicePixelRatio
			implicitHeight: 300 * Kirigami.Units.devicePixelRatio

			Layout.fillWidth: true
			Layout.fillHeight: true

			Image {
				id: singleColumnImage
				anchors.fill: parent
				source: plasmoid.file("", "images/singlecolumn.svg")
				smooth: true
				visible: false
			}

			ColorOverlay {
				anchors.fill: parent
				source: singleColumnImage
				color: syspal.text
				opacity: 0.8
			}
		}
	}
}
