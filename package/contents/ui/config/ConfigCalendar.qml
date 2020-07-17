import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import "../lib"

ConfigPage {
	id: page

	ConfigCheckBox {
		configKey: 'widget_show_calendar'
		text: i18n("Show calendar")
	}

	ConfigSection {
		ConfigRadioButtonGroup {
			id: clickDateGroup
			label: i18n("Click Date:")
			RadioButton {
				text: i18n("Scroll to event in Agenda")
				exclusiveGroup: clickDateGroup.exclusiveGroup
				checked: true
			}
		}
	}

	ConfigSection {
		ConfigRadioButtonGroup {
			id: doubleClickDateGroup
			label: i18n("DoubleClick Date:")
			RadioButton {
				text: i18n("Open New Event In Browser")
				exclusiveGroup: doubleClickDateGroup.exclusiveGroup
				checked: true
			}
		}
	}

	HeaderText {
		text: i18n("Style")
	}
	ConfigSection {
		ConfigCheckBox {
			configKey: 'month_show_border'
			text: i18n("Show Borders")
		}
		ConfigCheckBox {
			configKey: 'month_show_weeknumbers'
			text: i18n("Show Week Numbers")
		}
		ConfigCheckBox {
			configKey: 'monthHighlightCurrentDayWeek'
			text: i18n("Highlight Current Day / Week")
		}
		RowLayout {
			Label {
				text: i18n("First day of week:")
			}
			ComboBox {
				// [-1, 0, 1, 2, 3, 4, 5, 6] // Default = -1, 0..6 = Sun..Sat
				model: ListModel {}
				textRole: "text"

				Component.onCompleted: {
					model.append({
						text: i18n("Default"),
						value: -1,
					})
					for (var i = 0; i < 7; i++) {
						model.append({
							text: Qt.locale().dayName(i),
							value: i,
						})
					}

					// The firstDayOfWeek enum starts at -1 instead of 0
					currentIndex = plasmoid.configuration.firstDayOfWeek + 1
					currentIndexChanged.connect(function(){
						plasmoid.configuration.firstDayOfWeek = currentIndex - 1
					})
				}
			}
		}
		ConfigRadioButtonGroup {
			configKey: 'month_eventbadge_type'
			label: i18n("Event Badge:")
			model: [
				{ value: 'theme', text: i18n("Theme") },
				{ value: 'dots', text: i18n("Dots (3 Maximum)") },
				{ value: 'bottomBar', text: i18n("Bottom Bar (Event Color)") },
				{ value: 'bottomBarHighlight', text: i18n("Bottom Bar (Highlight)") },
				{ value: 'count', text: i18n("Count") },
			]
		}

		ConfigSlider {
			configKey: 'month_cell_radius'
			minimumValue: 0
			maximumValue: 1
			before: i18n("Radius:")
			after: "" + Math.round(value*100) + "%"
			Layout.fillWidth: false
		}

		ConfigRadioButtonGroup {
			id: selectedStyleGroup
			label: i18n("Selected:")
			RadioButton {
				text: i18n("Solid Color (Highlight)")
				exclusiveGroup: selectedStyleGroup.exclusiveGroup
				checked: true
			}
		}

		ConfigRadioButtonGroup {
			configKey: 'month_today_style'
			label: i18n("Today:")
			model: [
				{ value: 'theme', text: i18n("Solid Color (Inverted)") },
				{ value: 'bigNumber', text: i18n("Big Number") },
			]
		}
	}

}
