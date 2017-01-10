import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kcoreaddons 1.0 as KCoreAddons

ConfigPage {
	id: page
	
	ConfigSection {
		label: i18n("Breeze Battery Icon")

		ConfigCheckBox {
			text: i18n("Enabled")
			configKey: 'showBatteryIcon'
		}

		ConfigColor {
			value: "#1e1"
			label: i18n("Charging")
			enabled: false
		}
		ConfigColor {
			value: "#e11"
			label: i18n("Low Battery (under 20%)")
			enabled: false
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
			checked: false
			enabled: false
			// checked: plasmoid.configuration.timeLeftFormat
			// onClicked: plasmoid.configuration.timeLeftFormat = true
		}
		RadioButton {
			text: i18n("69m")
			exclusiveGroup: timeLeftFormatGroup
			checked: true
			enabled: false
			// checked: !plasmoid.configuration.timeLeftFormat
			// onClicked: plasmoid.configuration.timeLeftFormat = false
		}
	}
}