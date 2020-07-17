import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.private.digitalclock 1.0 as DigitalClock

import ".."
import "../lib"

// Mostly copied from digitalclock
ColumnLayout { // ConfigPage creates a binding loop when a child uses fillHeight
	id: page

	function digitalclock_i18n(message) {
		return i18nd("plasma_applet_org.kde.plasma.digitalclock", message)
	}

	DigitalClock.TimeZoneModel {
		id: timeZoneModel

		selectedTimeZones: plasmoid.configuration.selectedTimeZones
		onSelectedTimeZonesChanged: plasmoid.configuration.selectedTimeZones = selectedTimeZones
	}

	MessageWidget {
		id: messageWidget
	}

	TextField {
		id: filter
		Layout.fillWidth: true
		placeholderText: digitalclock_i18n("Search Time Zones")
	}

	TableView {
		id: timeZoneView
		Layout.fillWidth: true
		Layout.fillHeight: true

		signal toggleCurrent

		Keys.onSpacePressed: toggleCurrent()

		model: DigitalClock.TimeZoneFilterProxy {
			sourceModel: timeZoneModel
			filterString: filter.text
		}

		TableViewColumn {
			role: "city"
			title: digitalclock_i18n("City")
		}
		TableViewColumn {
			role: "region"
			title: digitalclock_i18n("Region")
		}
		TableViewColumn {
			role: "comment"
			title: digitalclock_i18n("Comment")
		}
		TableViewColumn {
			role: "checked"
			title: i18n("Tooltip")
			delegate: CheckBox {
				id: checkBox
				anchors.centerIn: parent
				checked: styleData.value
				activeFocusOnTab: false // only let the TableView as a whole get focus

				function setValue(checked) {
					if (!checked && model.region == "Local") {
						messageWidget.warn(i18n("Cannot deselect Local time from the tooltip"))
					} else {
						model.checked = checked // needed for model's setData to be called
					}
					checkBox.checked = Qt.binding(function(){ return styleData.value })
				}

				onClicked: checkBox.setValue(checked)

				Connections {
					target: timeZoneView
					onToggleCurrent: {
						if (styleData.row === timeZoneView.currentRow) {
							checkBox.setValue(!checkBox.checked)
						}
					}
				}
			}

			resizable: false
			movable: false
		}
	}


	ExclusiveGroup { id: timezoneDisplayType }
	RowLayout {
		Label {
			text: digitalclock_i18n("Display time zone as:")
		}

		RadioButton {
			id: timezoneCityRadio
			text: digitalclock_i18n("Time zone city")
			exclusiveGroup: timezoneDisplayType
			checked: !plasmoid.configuration.displayTimezoneAsCode
			onClicked: plasmoid.configuration.displayTimezoneAsCode = false
		}

		RadioButton {
			id: timezoneCodeRadio
			text: digitalclock_i18n("Time zone code")
			exclusiveGroup: timezoneDisplayType
			checked: plasmoid.configuration.displayTimezoneAsCode
			onClicked: plasmoid.configuration.displayTimezoneAsCode = true
		}
	}
}
