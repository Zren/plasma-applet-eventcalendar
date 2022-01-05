import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.private.digitalclock 1.0 as DigitalClock
import org.kde.kquickcontrolsaddons 2.0 // KCMShell

import "./lib"

Item {
	id: root

	Logger {
		id: logger
		name: 'eventcalendar'
		showDebug: plasmoid.configuration.debugging
		// showDebug: true
	}

	ConfigMigration { id: configMigration }
	AppletConfig { id: appletConfig }
	NotificationManager { id: notificationManager }
	NetworkMonitor { id: networkMonitor }

	property alias eventModel: eventModel
	property alias agendaModel: agendaModel
	
	TimeModel { id: timeModel }
	TimerModel { id: timerModel }
	EventModel { id: eventModel }
	UpcomingEvents { id: upcomingEvents }
	AgendaModel {
		id: agendaModel
		eventModel: eventModel
		timeModel: timeModel
		Component.onCompleted: logger.debug('AgendaModel.onCompleted')
	}
	Logic { id: logic }

	FontLoader {
		source: "../fonts/weathericons-regular-webfont.ttf"
	}

	Connections {
		target: plasmoid
		function onContextualActionsAboutToShow() {
			DigitalClock.ClipboardMenu.currentDate = timeModel.currentTime
		}
	}

	Plasmoid.toolTipItem: Loader {
		id: tooltipLoader

		Layout.minimumWidth: item ? item.width : 0
		Layout.maximumWidth: item ? item.width : 0
		Layout.minimumHeight: item ? item.height : 0
		Layout.maximumHeight: item ? item.height : 0

		source: "TooltipView.qml"
	}

	// org.kde.plasma.mediacontrollercompact
	PlasmaCore.DataSource {
		id: executable
		engine: "executable"
		connectedSources: []
		onNewData: disconnectSource(sourceName) // cmd finished
		function exec(cmd) {
			connectSource(cmd)
		}
	}

	property Component clockComponent: ClockView {
		id: clock

		currentTime: timeModel.currentTime

		MouseArea {
			id: mouseArea
			anchors.fill: parent

			property int wheelDelta: 0

			onClicked: {
				if (mouse.button == Qt.LeftButton) {
					plasmoid.expanded = !plasmoid.expanded
				}
			}

			onWheel: {
				var delta = wheel.angleDelta.y || wheel.angleDelta.x
				wheelDelta += delta

				// Magic number 120 for common "one click"
				// See: https://doc.qt.io/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
				while (wheelDelta >= 120) {
					wheelDelta -= 120
					onScrollUp()
				}
				while (wheelDelta <= -120) {
					wheelDelta += 120
					onScrollDown()
				}
			}

			function onScrollUp() {
				if (plasmoid.configuration.clockMouseWheel === 'RunCommands') {
					executable.exec(plasmoid.configuration.clockMouseWheelUp)
				}
			}
			function onScrollDown() {
				if (plasmoid.configuration.clockMouseWheel === 'RunCommands') {
					executable.exec(plasmoid.configuration.clockMouseWheelDown)
				}
			}
		}
	}

	property Component popupComponent: PopupView {
		id: popup

		eventModel: root.eventModel
		agendaModel: root.agendaModel

		// If pin is enabled, we need to add some padding around the popup unless
		// * we're a desktop widget (no need)
		// * the timer widget is enabled since there's room in the top right
		property bool isPinVisible: {
			// plasmoid.location == PlasmaCore.Types.Floating when using plasmawindowed and when used as a desktop widget.
			return plasmoid.location != PlasmaCore.Types.Floating // && plasmoid.configuration.widget_show_pin
		}
		padding: {
			if (isPinVisible && !(plasmoid.configuration.widgetShowTimer || plasmoid.configuration.widgetShowMeteogram)) {
				return pinButton.height
			} else {
				return 0
			}
		}

		property bool isExpanded: plasmoid.expanded
		onIsExpandedChanged: {
			logger.debug('isExpanded', isExpanded)
			if (isExpanded) {
				updateToday()
				logic.updateWeather()
			}
		}

		function updateToday() {
			setToday(timeModel.currentTime)
		}

		function setToday(d) {
			logger.debug('setToday', d)
			today = d
			// console.log(root.timezone, dataSource.data[root.timezone]["DateTime"])
			logger.debug('currentTime', timeModel.currentTime)
			monthViewDate = today
			selectedDate = today
			scrollToSelection()
		}

		Connections {
			target: timeModel
			onDateChanged: {
				popup.updateToday()
				logger.debug('root.onDateChanged', timeModel.currentTime, popup.today)
			}
		}

		Binding {
			target: plasmoid
			property: "hideOnWindowDeactivate"
			value: !plasmoid.configuration.pin
		}

		// Allows the user to keep the calendar open for reference
		PlasmaComponents3.ToolButton {
			id: pinButton
			visible: isPinVisible
			anchors.right: parent.right
			width: Math.round(units.gridUnit * 1.25)
			height: width
			checkable: true
			icon.name: "window-pin"
			checked: plasmoid.configuration.pin
			onCheckedChanged: plasmoid.configuration.pin = checked
		}

	}

	Plasmoid.backgroundHints: plasmoid.configuration.showBackground ? PlasmaCore.Types.DefaultBackground : PlasmaCore.Types.NoBackground

	property bool isDesktopContainment: plasmoid.location == PlasmaCore.Types.Floating
	Plasmoid.preferredRepresentation: isDesktopContainment ? Plasmoid.fullRepresentation : Plasmoid.compactRepresentation
	Plasmoid.compactRepresentation: clockComponent
	Plasmoid.fullRepresentation: popupComponent

	function action_KCMClock() {
		// Note: https://invent.kde.org/plasma/plasma-workspace/-/commit/4e34ba26e6fc53dc47e7079d863e15408534dcf6
		// Note: KCMShell.open uses kcmshell5 which converts "translations" => "kcm_translations".
		// Note: https://github.com/KDE/kde-cli-tools/blob/master/kcmshell/main.cpp
		// Note: systemsettings5 needs the exact name.
		// TODO: Use KCMShell.openSystemSettings("kcm_clock") once we no longer need to support Plasma 5.23
		KCMShell.open([
			"kcm_clock", // Plasma 5.24
			"clock" // Plasma 5.23
		])
	}

	function action_KCMTranslations() {
		// Note: https://invent.kde.org/plasma/plasma-workspace/-/commit/68b2a75568563223cc79d585bdae7ca7e0aeb54a
		KCMShell.open([
			"kcm_translations", // Plasma 5.15
			"translations" // Plasma 5.14
		])
	}

	function action_KCMFormats() {
		KCMShell.open([
			"kcm_formats", // Plasma 5.24
			"formats" // Plasma 5.23
		])
	}

	Component.onCompleted: {
		plasmoid.setAction("clipboard", i18nd("plasma_applet_org.kde.plasma.digitalclock", "Copy to Clipboard"), "edit-copy")
		DigitalClock.ClipboardMenu.setupMenu(plasmoid.action("clipboard"))

		// An uninstalled KCM like 'user_manager.desktop' in Plasma 5.20 is returned
		// in the output list, so we need to check if user has permission for both.
		if (KCMShell.authorize([
			"kcm_clock.desktop", // Plasma 5.24
			"clock.desktop" // Plasma 5.23
		]).length == 2) {
			// DigitalClock uses symbolic "clock" icon in Plasma 5.24
			plasmoid.setAction("KCMClock", i18nd("plasma_applet_org.kde.plasma.digitalclock", "Adjust Date and Time…"), "preferences-system-time")
		}
		if (KCMShell.authorize([
			"kcm_translations.desktop", // Plasma 5.15
			"translations.desktop", // Plasma 5.14
		]).length == 2) {
			plasmoid.setAction("KCMTranslations", i18n("Set Language…"), "preferences-desktop-locale")
		}
		if (KCMShell.authorize([
			"kcm_formats.desktop", // Plasma 5.24
			"formats.desktop" // Plasma 5.23
		]).length == 2) {
			// DigitalClock uses symbolic "gnumeric-format-thousand-separator" icon in Plasma 5.24
			plasmoid.setAction("KCMFormats", i18n("Set Locale…"), "preferences-desktop-locale")
		}

		// plasmoid.action("configure").trigger()
	}

	// Timer {
	// 	interval: 400
	// 	running: true
	// 	onTriggered: {
	// 		plasmoid.expanded = true
	// 		root.Plasmoid.fullRepresentationItem.Layout.minimumWidth = 1000
	// 		root.Plasmoid.fullRepresentationItem.Layout.minimumHeight = 600
	// 	}
	// }
}
