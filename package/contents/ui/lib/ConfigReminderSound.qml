// Version 5

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configReminderSound
	property alias label: reminderSfxEnabledCheckBox.text
	property alias sfxEnabledKey: reminderSfxEnabledCheckBox.configKey
	property alias sfxPathKey: reminderSfxPath.configKey

	property alias sfxEnabled: reminderSfxEnabledCheckBox.checked
	property alias sfxPathValue: reminderSfxPath.value
	property alias sfxPathDefaultValue: reminderSfxPath.defaultValue

	// Importing QtMultimedia apparently segfaults both OpenSUSE and Kubuntu.
	// https://github.com/Zren/plasma-applet-eventcalendar/issues/84
	// https://github.com/Zren/plasma-applet-eventcalendar/issues/167
	// property var reminderSfxTest: Qt.createQmlObject("import QtMultimedia 5.4; Audio {}", configSound)
	property var reminderSfxTest: null

	spacing: 0
	ConfigCheckBox {
		id: reminderSfxEnabledCheckBox
	}
	Button {
		iconName: "media-playback-start-symbolic"
		enabled: sfxEnabled && !!sfxTest
		onClicked: {
			sfxTest.source = sfxPath.value
			sfxTest.play()
		}
	}
	ConfigString {
		id: sfxPath
		enabled: sfxEnabled
		Layout.fillWidth: true
	}
	Button {
		iconName: "folder-symbolic"
		enabled: sfxEnabled
		onClicked: sfxPathDialog.visible = true

		FileDialog {
			id: sfxPathDialog
			title: i18n("Choose a sound effect")
			folder: '/usr/share/sounds'
			nameFilters: [
				i18n("Sound files (%1)", "*.wav *.mp3 *.oga *.ogg"),
				i18n("All files (%1)", "*"),
			]
			onAccepted: {
				sfxPathValue = fileUrl
			}
		}
	}
}
