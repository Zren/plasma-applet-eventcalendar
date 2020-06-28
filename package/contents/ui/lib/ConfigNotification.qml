// Version 4

import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

ColumnLayout {
	id: configNotification
	property alias label: notificationEnabledCheckBox.text
	property alias notificationEnabledKey: notificationEnabledCheckBox.configKey

	property alias notificationEnabled: notificationEnabledCheckBox.checked

	property alias sfxLabel: configSound.label
	property alias sfxEnabledKey: configSound.sfxEnabledKey
	property alias sfxPathKey: configSound.sfxPathKey

	property alias sfxEnabled: configSound.sfxEnabled
	property alias sfxPathValue: configSound.sfxPathValue
	property alias sfxPathDefaultValue: configSound.sfxPathDefaultValue

	property int indentWidth: 24 * units.devicePixelRatio

	ConfigCheckBox {
		id: notificationEnabledCheckBox
	}

	RowLayout {
		spacing: 0
		Item { implicitWidth: indentWidth } // indent
		ConfigSound {
			id: configSound
			label: i18n("SFX:")
			enabled: notificationEnabled
		}
	}
}
