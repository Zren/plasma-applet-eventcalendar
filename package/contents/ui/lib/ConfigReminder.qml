import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

ColumnLayout {
	id: configReminder
	property alias label: reminderEnabledCheckBox.text
	property alias reminderEnabledKey: reminderEnabledCheckBox.configKey

	property alias reminderEnabled: reminderEnabledCheckBox.checked

	property alias sfxLabel: configReminderSound.label
	property alias sfxEnabledKey: configReminderSound.sfxEnabledKey
	property alias sfxPathKey: configReminderSound.sfxPathKey

	property alias sfxEnabled: configReminderSound.sfxEnabled
	property alias sfxPathValue: configReminderSound.sfxPathValue
	property alias sfxPathDefaultValue: configReminderSound.sfxPathDefaultValue

	property int indentWidth: 24 * units.devicePixelRatio

	ConfigCheckBox {
		id: reminderEnabledCheckBox
	}

	RowLayout{
		spacing: 0
		Item { implicitWidth: indentWidth } // indent
		ConfigSpinBox {
			configKey: 'reminderTime'
			before: i18n("Reminder x minutes before event: ")
			suffix: i18nc("minutes", "min")
			minimumValue: 5
			maximumValue: 90
		}
	}

	RowLayout {
		spacing: 0
		Item { implicitWidth: indentWidth } // indent
		ConfigSound {
			id: configReminderSound
			label: i18n("SFX:")
			enabled: reminderEnabled
		}
	}
}
