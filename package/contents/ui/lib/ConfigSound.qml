// Version 5

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0

RowLayout {
	id: configSound
	property alias label: sfxEnabledCheckBox.text
	property alias sfxEnabledKey: sfxEnabledCheckBox.configKey
	property alias sfxPathKey: sfxPath.configKey

	property alias sfxEnabled: sfxEnabledCheckBox.checked
	property alias sfxPathValue: sfxPath.value
	property alias sfxPathDefaultValue: sfxPath.defaultValue

	// Importing QtMultimedia apparently segfaults both OpenSUSE and Kubuntu.
	// https://github.com/Zren/plasma-applet-eventcalendar/issues/84
	// https://github.com/Zren/plasma-applet-eventcalendar/issues/167
	// property var sfxTest: Qt.createQmlObject("import QtMultimedia 5.4; Audio {}", configSound)
	property var sfxTest: null

	spacing: 0
	ConfigCheckBox {
		id: sfxEnabledCheckBox
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
