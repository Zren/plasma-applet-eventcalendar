import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import ".."
import "../lib"

ConfigPage {
	id: page
	showAppletVersion: true

	property string cfg_clickCommand

	DesktopEffectToggle {
		id: presentWindowsToggle
		label: i18n("Present Windows Effect")
		effectId: 'presentwindows'
		Label {
			visible: presentWindowsToggle.loaded && !presentWindowsToggle.effectEnabled
			text: i18n("Button will not work when the Present Windows desktop effect is disabled.")
		}
	}

	DesktopEffectToggle {
		id: showDesktopGridToggle
		label: i18n("Show Desktop Grid Effect")
		effectId: 'desktopgrid'
		Label {
			visible: showDesktopGridToggle.loaded && !showDesktopGridToggle.effectEnabled
			text: i18n("Button will not work when the Desktop Grid desktop effect is disabled.")
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
		RadioButton {
			text: i18nd("kwin_effects", "Toggle Desktop Grid")
			checked: cfg_clickCommand == 'ShowDesktopGrid'
			exclusiveGroup: clickCommandGroup
			onClicked: cfg_clickCommand = 'ShowDesktopGrid'
		}
	}


	ConfigSection {
		label: i18n("Icon")

		ConfigIcon {
			configKey: 'icon'
			defaultValue: 'presentwindows-24px'
		}
	}

}
