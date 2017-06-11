import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	property string cfg_clickCommand


	ExclusiveGroup { id: clickCommandGroup }
	ConfigSection {
		label: i18n("SubHeading")

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
			checked: cfg_clickCommand == 'ExposeAll'
			exclusiveGroup: clickCommandGroup
			onClicked: cfg_clickCommand = 'ExposeClass'
		}
	}

}
