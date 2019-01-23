import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "../lib"

ConfigPage {
	id: page

	property alias cfg_widget_show_calendar: widget_show_calendar.checked
	property alias cfg_month_show_border: month_show_border.checked
	property alias cfg_month_show_weeknumbers: month_show_weeknumbers.checked
	property string cfg_month_eventbadge_type: 'bottomBar'
	property string cfg_month_today_style: 'theme'

	CheckBox {
		Layout.fillWidth: true
		id: widget_show_calendar
		text: i18n("Show calendar")
	}
	
	ConfigSection {
		LabeledRowLayout {
			label: i18n("Click Date:")
			ExclusiveGroup { id: month_date_clickGroup }
			RadioButton {
				text: i18n("Scroll to event in Agenda")
				checked: true
				exclusiveGroup: month_date_clickGroup
			}
		}
	}

	ConfigSection {
		LabeledRowLayout {
			label: i18n("DoubleClick Date:")
			ExclusiveGroup { id: month_date_doubleclickGroup }
			RadioButton {
				text: i18n("Open New Event In Browser")
				checked: true
				exclusiveGroup: month_date_doubleclickGroup
			}
		}
	}

	HeaderText {
		text: i18n("Style")
	}
	ConfigSection {
		CheckBox {
			id: month_show_border
			text: i18n("Show Borders")
		}
		CheckBox {
			id: month_show_weeknumbers
			text: i18n("Show Week Numbers")
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
		LabeledRowLayout {
			label: i18n("Event Badge:")
			ExclusiveGroup { id: month_eventbadge_styleGroup }
			RadioButton {
				text: i18n("Theme")
				exclusiveGroup: month_eventbadge_styleGroup
				checked: cfg_month_eventbadge_type == 'theme'
				onClicked: {
					cfg_month_eventbadge_type = 'theme'
				}
			}
			RadioButton {
				text: i18n("Dots (3 Maximum)")
				exclusiveGroup: month_eventbadge_styleGroup
				checked: cfg_month_eventbadge_type == 'dots'
				onClicked: {
					cfg_month_eventbadge_type = 'dots'
				}
			}
			RadioButton {
				text: i18n("Bottom Bar (Event Color)")
				exclusiveGroup: month_eventbadge_styleGroup
				checked: cfg_month_eventbadge_type == 'bottomBar'
				onClicked: {
					cfg_month_eventbadge_type = 'bottomBar'
				}
			}
			RadioButton {
				text: i18n("Bottom Bar (Highlight)")
				exclusiveGroup: month_eventbadge_styleGroup
				checked: cfg_month_eventbadge_type == 'bottomBarHighlight'
				onClicked: {
					cfg_month_eventbadge_type = 'bottomBarHighlight'
				}
			}
			RadioButton {
				text: i18n("Count")
				exclusiveGroup: month_eventbadge_styleGroup
				checked: cfg_month_eventbadge_type == 'count'
				onClicked: {
					cfg_month_eventbadge_type = 'count'
				}
			}
		}

		ConfigSlider {
			configKey: 'month_cell_radius'
			minimumValue: 0
			maximumValue: 1
			before: i18n("Radius:")
			after: "" + Math.round(value*100) + "%"
		}

		LabeledRowLayout {
			label: i18n("Selected:")
			ExclusiveGroup { id: month_selected_styleGroup }
			RadioButton {
				visible: false
				enabled: false
				text: i18n("Theme")
				exclusiveGroup: month_selected_styleGroup
			}
			RadioButton {
				text: i18n("Solid Color (Highlight)")
				checked: true
				exclusiveGroup: month_selected_styleGroup
			}
		}

		LabeledRowLayout {
			label: i18n("Today:")
			ExclusiveGroup { id: month_today_styleGroup }
			RadioButton {
				visible: false
				enabled: false
				text: i18n("Theme")
				exclusiveGroup: month_today_styleGroup
			}
			RadioButton {
				text: i18n("Solid Color (Inverted)")
				exclusiveGroup: month_today_styleGroup
				checked: cfg_month_today_style == 'theme'
				onClicked: cfg_month_today_style = 'theme'
			}
			RadioButton {
				text: i18n("Big Number")
				exclusiveGroup: month_today_styleGroup
				checked: cfg_month_today_style == 'bigNumber'
				onClicked: cfg_month_today_style = 'bigNumber'
			}
		}
	}

}
