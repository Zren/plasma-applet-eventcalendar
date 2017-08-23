import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kcoreaddons 1.0 as KCoreAddons

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	AppletConfig { id: config }
	
	ConfigSection {
		label: i18n("Breeze Battery Icon")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showBatteryIcon'
		}

		ConfigColor {
			label: i18n("Normal")
			configKey: 'normalColor'
			defaultColor: config.defaultNormalColor
		}

		ConfigColor {
			label: i18n("Charging")
			configKey: 'chargingColor'
			defaultColor: config.defaultChargingColor
		}
		RowLayout {
			ConfigSpinBox {
				before: i18n("Low Battery")
				suffix: '%'
				configKey: 'lowBatteryPercent'
				minimumValue: 0
				maximumValue: 100
			}
			ConfigColor {
				label: ''
				configKey: 'lowBatteryColor'
				defaultColor: config.defaultLowBatteryColor
			}
		}
	}

	ConfigSection {
		label: i18n("Percentage")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showPercentage'
		}
	}

	ExclusiveGroup { id: timeLeftFormatGroup }
	ConfigSection {
		label: i18n("Time Left")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showTimeLeft'
		}

		RadioButton {
			text: KCoreAddons.Format.formatDuration(69 * 1000, KCoreAddons.FormatTypes.HideSeconds)
			exclusiveGroup: timeLeftFormatGroup
			// checked: false
			// enabled: false
			checked: config.timeLeftUseLocaleFormat
			onClicked: plasmoid.configuration.timeLeftFormat = ''
		}
		RadioButton {
			text: i18n("69m")
			exclusiveGroup: timeLeftFormatGroup
			// checked: true
			// enabled: false
			checked: !config.timeLeftUseLocaleFormat
			onClicked: plasmoid.configuration.timeLeftFormat = '69m'
		}
	}
}