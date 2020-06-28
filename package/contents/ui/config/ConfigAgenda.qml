import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import ".."
import "../lib"

ConfigPage {
	id: page

	property int indentWidth: 24 * units.devicePixelRatio

	ConfigCheckBox {
		configKey: 'widget_show_agenda'
		text: i18n("Show agenda")
	}

	ConfigSection {
		ConfigSpinBox {
			configKey: 'agenda_fontSize'
			before: i18n("Font Size:")
			suffix: i18n("px")
			after: i18n(" (0px = <b>System Settings > Fonts > General</b>)")
		}
	}

	ConfigSection {
		RowLayout {
			ConfigCheckBox {
				configKey: 'agenda_weather_show_icon'
				checked: true
				text: i18n("Weather Icon")
			}
			ConfigSlider {
				configKey: 'agenda_weather_icon_height'
				minimumValue: 12
				maximumValue: 48
				stepSize: 1
				after: '' + value + i18n("px")
				Layout.fillWidth: false
			}
		}

		RowLayout {
			Text { width: indentWidth } // Indent
			ConfigCheckBox {
				configKey: 'show_outlines'
				text: i18n("Icon Outline")
			}
		}

		ConfigCheckBox {
			configKey: 'agenda_weather_show_text'
			text: i18n("Weather Text")
		}

		LabeledRowLayout {
			label: i18n("Position:")
			ExclusiveGroup { id: agendaWeatherOnRightGroup }
			RadioButton {
				text: i18n("Left")
				exclusiveGroup: agendaWeatherOnRightGroup
				checked: !plasmoid.configuration.agendaWeatherOnRight
				onClicked: plasmoid.configuration.agendaWeatherOnRight = false
			}
			RadioButton {
				text: i18n("Right")
				exclusiveGroup: agendaWeatherOnRightGroup
				checked: plasmoid.configuration.agendaWeatherOnRight
				onClicked: plasmoid.configuration.agendaWeatherOnRight = true
			}
		}

		LabeledRowLayout {
			label: i18n("Click Weather:")
			ExclusiveGroup { id: agenda_weather_clickGroup }
			RadioButton {
				text: i18n("Open City Forecast In Browser")
				exclusiveGroup: agenda_weather_clickGroup
				checked: true
			}
		}
	}

	ConfigSection {
		LabeledRowLayout {
			label: i18n("Click Date:")
			ExclusiveGroup { id: agenda_date_clickGroup }
			RadioButton {
				text: i18n("Open New Event In Browser")
				exclusiveGroup: agenda_date_clickGroup
				enabled: false
			}
			RadioButton {
				text: i18n("Open New Event Form")
				exclusiveGroup: agenda_date_clickGroup
				checked: true
			}
		}
	}

	ConfigSection {
		ConfigCheckBox {
			configKey: 'agendaShowEventDescription'
			text: i18n("Event description")
		}
		ConfigCheckBox {
			configKey: 'agendaCondensedAllDayEvent'
			text: i18n("Hide 'All Day' text")
		}
		ConfigCheckBox {
			configKey: 'agendaShowEventHangoutLink'
			text: i18n("Google Hangouts link")
		}
		LabeledRowLayout {
			label: i18n("Click Event:")
			ExclusiveGroup { id: agenda_event_clickGroup }
			RadioButton {
				text: i18n("Open Event In Browser")
				checked: true
				exclusiveGroup: agenda_event_clickGroup
			}
		}
	}


	ConfigSection {
		LabeledRowLayout {
			label: i18n("Show multi-day events:")
			ExclusiveGroup { id: agendaBreakupMultidayEventsGroup }
			RadioButton {
				text: i18n("On all days")
				exclusiveGroup: agendaBreakupMultidayEventsGroup
				checked: plasmoid.configuration.agenda_breakup_multiday_events
				onClicked: plasmoid.configuration.agenda_breakup_multiday_events = true
			}
			RadioButton {
				text: i18n("Only on the first and current day")
				exclusiveGroup: agendaBreakupMultidayEventsGroup
				checked: !plasmoid.configuration.agenda_breakup_multiday_events
				onClicked: plasmoid.configuration.agenda_breakup_multiday_events = false
			}
		}
	}

	ConfigSection {
		ConfigCheckBox {
			configKey: 'agenda_newevent_remember_calendar'
			text: i18n("Remember selected calendar in New Event Form")
		}
	}

	ConfigSection {
		title: i18n("Current Month")

		CheckBox {
			enabled: false
			checked: true
			text: i18n("Always show next 14 days")
		}
		CheckBox {
			enabled: false
			checked: false
			text: i18n("Hide completed events")
		}
		CheckBox {
			enabled: false
			checked: true
			text: i18n("Show all events of the current day (including completed events)")
		}
	}

	AppletConfig { id: config }
	ColorGrid {
		title: i18n("Colors")

		ConfigColor {
			configKey: 'agenda_inProgressColor'
			label: i18n("In Progress")
			defaultColor: config.agendaInProgressColorDefault
		}
	}

	ConfigSection {
		ConfigSpinBox {
			configKey: 'agendaDaySpacing'
			before: i18n("Day Spacing:")
			suffix: i18n("px")
		}
		ConfigSpinBox {
			configKey: 'agendaEventSpacing'
			before: i18n("Event Spacing:")
			suffix: i18n("px")
		}
	}

}
