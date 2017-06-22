import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

ConfigSection {
	label: "Desktop Effect Toggle"
	property string effectId
	property bool loaded: false
	property bool effectEnabled: true

	ExecUtil {
		id: executable
		property string readStateCommand: 'qdbus org.kde.KWin /Effects isEffectLoaded ' + effectId
		property string toggleStateCommand: 'qdbus org.kde.KWin /Effects toggleEffect ' + effectId

		function readState() {
			executable.exec(readStateCommand)
		}
		function toggleState() {
			executable.exec(toggleStateCommand)
		}
		Component.onCompleted: {
			readState()
		}

		onExited: {
			if (command == readStateCommand) {
				var value = executable.trimOutput(stdout)
				value = value === 'true' // cast to boolean
				effectEnabled = value
				toggleButton.checked = value
				loaded = true
			} else if (command == toggleStateCommand) {
				readState()
			}
		}
	}

	CheckBox {
		id: toggleButton
		text: i18n("Enabled")
		onClicked: {
			executable.toggleState()
		}
	}
}
