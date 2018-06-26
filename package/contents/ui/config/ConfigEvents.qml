import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.calendar 2.0 as PlasmaCalendar

import "../lib"

ConfigPage {
	id: page

	HeaderText {
		text: i18n("Event Calendar Plugins")
	}

	ConfigSection {
		CheckBox {
			text: i18n("ICalendar (.ics)")
			checked: true
			enabled: false
			visible: plasmoid.configuration.debugging
		}
		CheckBox {
			text: i18n("Google Calendar")
			checked: true
			enabled: false
		}
	}


	HeaderText {
		text: i18n("Plasma Calendar Plugins")
	}

	// From digitalclock's configCalendar.qml
	signal configurationChanged()
	ConfigSection {
		Repeater {
			id: calendarPluginsRepeater
			model: PlasmaCalendar.EventPluginsManager.model
			delegate: CheckBox {
				text: model.display
				checked: model.checked
				onClicked: {
					model.checked = checked // needed for model's setData to be called
					// page.configurationChanged()
					page.saveConfig()
				}
			}
		}
	}
	function saveConfig() {
		plasmoid.configuration.enabledCalendarPlugins = PlasmaCalendar.EventPluginsManager.enabledPlugins
	}
	Component.onCompleted: {
		PlasmaCalendar.EventPluginsManager.populateEnabledPluginsList(plasmoid.configuration.enabledCalendarPlugins)
	}

	HeaderText {
		text: i18n("Misc")
	}
	ColumnLayout {

		ConfigSpinBox {
			configKey: 'events_pollinterval'
			before: i18n("Refresh events every: ")
			suffix: i18ncp("Polling interval in minutes", "min", "min", value)
			minimumValue: 5
			maximumValue: 90
		}
	}

	HeaderText {
		text: i18n("Notifications")
	}

	ConfigSection {
		ConfigNotification {
			label: i18n("Event Starting")
			notificationEnabledKey: 'eventStartingNotificationEnabled'
			sfxEnabledKey: 'eventStartingSfxEnabled'
			sfxPathKey: 'eventStartingSfxPath'
			sfxPathDefaultValue: '/usr/share/sounds/KDE-Im-Nudge.ogg'
		}
	}

}
