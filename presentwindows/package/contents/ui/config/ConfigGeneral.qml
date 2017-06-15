import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	property string cfg_clickCommand

	ExecUtil {
		id: executable
		property string readStateCommand: 'qdbus org.kde.KWin /Effects isEffectLoaded presentwindows'
		property string toggleStateCommand: 'qdbus org.kde.KWin /Effects toggleEffect presentwindows'

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
				value = !!value // cast to boolean
				kwin_presentwindowsEnabled.checked = value
			} else if (command == toggleStateCommand) {
				readState()
			}
		}
	}
	
	ConfigSection {
		label: i18n("Present Windows Effect")

		CheckBox {
			id: kwin_presentwindowsEnabled
			text: i18n("Enabled")
			onClicked: {
				executable.toggleState()
			}
		}
		Label {
			text: i18n("Button will not work when Present Windows Desktop Effect is disabled.")
		}
	}


	ExclusiveGroup { id: clickCommandGroup }
	ConfigSection {
		label: i18n("Click")

		RadioButton {
			text: i18nd("kwin_effects", "Toggle Present Windows (All desktops)")
			checked: cfg_clickCommand == 'ExposeAll'
			exclusiveGroup: clickCommandGroup
			onClicked: cfg_clickCommand = 'ExposeAll'
		}
		RadioButton {
			text: i18nd("kwin_effects", "Toggle Present Windows (Current desktop)")
			checked: cfg_clickCommand == 'Expose'
			exclusiveGroup: clickCommandGroup
			onClicked: cfg_clickCommand = 'Expose'
		}
		RadioButton {
			text: i18nd("kwin_effects", "Toggle Present Windows (Window class)")
			checked: cfg_clickCommand == 'ExposeClass'
			exclusiveGroup: clickCommandGroup
			onClicked: cfg_clickCommand = 'ExposeClass'
		}
	}

}
