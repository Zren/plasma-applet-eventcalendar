import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

import "lib"

Item {
	id: widget

	QtObject {
		id: config
		property string icon: 'presentwindows-24px'
	}

	Plasmoid.onActivated: widget.activate()

	Plasmoid.preferredRepresentation: Plasmoid.fullRepresentation
	Plasmoid.fullRepresentation: AppletIcon {
		id: icon

		readonly property bool inPanel: (plasmoid.location == PlasmaCore.Types.TopEdge
			|| plasmoid.location == PlasmaCore.Types.RightEdge
			|| plasmoid.location == PlasmaCore.Types.BottomEdge
			|| plasmoid.location == PlasmaCore.Types.LeftEdge)

		Layout.minimumWidth: {
			switch (plasmoid.formFactor) {
			case PlasmaCore.Types.Vertical:
				return 0;
			case PlasmaCore.Types.Horizontal:
				return height;
			default:
				return units.gridUnit * 3;
			}
		}

		Layout.minimumHeight: {
			switch (plasmoid.formFactor) {
			case PlasmaCore.Types.Vertical:
				return width;
			case PlasmaCore.Types.Horizontal:
				return 0;
			default:
				return units.gridUnit * 3;
			}
		}

		Layout.maximumWidth: inPanel ? units.iconSizeHints.panel : -1
		Layout.maximumHeight: inPanel ? units.iconSizeHints.panel : -1

		source: config.icon
		active: mouseArea.containsMouse

		MouseArea {
			id: mouseArea
			anchors.fill: parent
			hoverEnabled: true
			onClicked: widget.activate()
		}
	}

	PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: disconnectSource(sourceName)

		function exec(cmd) {
			executable.connectSource(cmd)
		}
	}

	function action_exposeAll() {
		executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeAll"')
	}

	function action_exposeDesktop() {
		executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Expose"')
	}

	function action_exposeWindowClass() {
		executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ExposeClass"')
	}

	function action_showDesktopGrid() {
		executable.exec('qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "ShowDesktopGrid"')
	}

	function activate() {
		if (plasmoid.configuration.clickCommand == 'ExposeAll') {
			action_exposeAll()
		} else if (plasmoid.configuration.clickCommand == 'Expose') {
			action_exposeDesktop()
		} else if (plasmoid.configuration.clickCommand == 'ExposeClass') {
			action_exposeWindowClass()
		} else if (plasmoid.configuration.clickCommand == 'ShowDesktopGrid') {
			action_showDesktopGrid()
		}
	}

	Component.onCompleted: {
		plasmoid.setAction("exposeAll", i18n("Present Windows (All desktops)"), "window");
		plasmoid.setAction("exposeDesktop", i18n("Present Windows (Current desktop)"), "window");
		plasmoid.setAction("exposeWindowClass", i18n("Present Windows (Window class)"), "window");
		plasmoid.setAction("showDesktopGrid", i18n("Show Desktop Grid"), "view-grid");

		// plasmoid.action('configure').trigger() // Uncomment to open the config window on load.
	}
}
