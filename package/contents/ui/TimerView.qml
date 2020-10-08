import QtQuick 2.0
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: timerView

	property int timerSeconds: 0
	property int timerDuration: 0
	property alias timerRepeats: timerRepeatsButton.isChecked
	property alias timerSfxEnabled: timerSfxEnabledButton.isChecked

	property bool setTimerViewVisible: false

	implicitHeight: timerButtonView.height

	function getHours(t) {
		var hours = Math.floor(t / (60 * 60 * 1000))
		return hours
	}
	function getMinutes(t) {
		var millisLeftInHour = t % (60 * 60 * 1000)
		var minutes = millisLeftInHour / (60 * 1000)
		return minutes
	}
	function getSeconds(t) {
		var millisLeftInMinute = t % (60 * 1000)
		var seconds = millisLeftInMinute / 1000
		return seconds
	}
	function durationShortFormat(totalSeconds) {
		var t = totalSeconds * 1000
		var str = ''
		var hours = Math.floor(getHours(t))
		if (hours > 0) {
			str += i18nc("short form for %1 hours", "%1h", hours)
		}
		var minutes = Math.floor(getMinutes(t))
		if (minutes > 0) {
			str += i18nc("short form for %1 minutes", "%1m", minutes)
		}
		var seconds = Math.floor(getSeconds(t))
		if (seconds > 0) {
			str += i18nc("short form for %1 seconds", "%1s", seconds)
		}
		return str
	}
	property var defaultTimers: [
		{ seconds: 30 },
		{ seconds: 60 },
		{ seconds: 5 * 60 },
		{ seconds: 10 * 60 },
		{ seconds: 15 * 60 },
		{ seconds: 20 * 60 },
		{ seconds: 30 * 60 },
		{ seconds: 45 * 60 },
		{ seconds: 60 * 60 },
	]

	ColumnLayout {
		id: timerButtonView
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 4
		
		opacity: timerView.setTimerViewVisible ? 0 : 1
		visible: opacity > 0
		Behavior on opacity {
			NumberAnimation { duration: 200 }
		}

		onWidthChanged: {
			// console.log('timerButtonView.width', width)
			bottomRow.updatePresetVisibilities()
		}


		RowLayout {
			id: topRow
			spacing: 10 * units.devicePixelRatio
			property int contentsWidth: timerLabel.width + topRow.spacing + toggleButtonColumn.Layout.preferredWidth
			property bool contentsFit: timerButtonView.width >= contentsWidth

			PlasmaComponents3.ToolButton {
				id: timerLabel
				text: "0:00"
				icon.name: {
					if (timerSeconds == 0) {
						return 'chronometer'
					} else if (timerTicker.running) {
						return 'chronometer-pause'
					} else {
						return 'chronometer-start'
					}
				}
				icon.width: units.iconSizes.large
				icon.height: units.iconSizes.large
				font.pointSize: -1
				font.pixelSize: appletConfig.timerClockFontHeight
				Layout.alignment: Qt.AlignVCenter
				property string tooltip: {
					var s = ""
					if (timerSeconds > 0) {
						if (timerTicker.running) {
							s += i18n("Pause Timer")
						} else {
							s += i18n("Start Timer")
						}
						s += "\n"
					}
					s += i18n("Scroll to add to duration")
					return s
				}
				QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
				QQC2.ToolTip.text: tooltip
				QQC2.ToolTip.visible: hovered

				onClicked: {
					if (timerTicker.running) {
						timerTicker.stop()
					} else if (timerSeconds > 0) {
						timerTicker.start()
					} else { // timerSeconds == 0
						// ignore
					}
				}

				MouseArea {
					acceptedButtons: Qt.RightButton
					anchors.fill: parent

					// onClicked: contextMenu.show(mouse.x, mouse.y)
					onClicked: contextMenu.showBelow(timerLabel)
				}

				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.MiddleButton

					onWheel: {
						var delta = wheel.angleDelta.y || wheel.angleDelta.x
						if (delta > 0) {
							setDuration(timerDuration + 60)
							timerTicker.stop()
						} else if (delta < 0) {
							setDuration(timerDuration - 60)
							timerTicker.stop()
						}
					}
				}
			}
			
			ColumnLayout {
				id: toggleButtonColumn
				Layout.alignment: Qt.AlignBottom
				Layout.minimumWidth: sizingButton.height
				Layout.preferredWidth: sizingButton.implicitWidth

				PlasmaComponents3.ToolButton {
					id: sizingButton
					text: "Test"
					visible: false
				}
				
				PlasmaComponents3.ToolButton {
					id: timerRepeatsButton
					readonly property bool isChecked: plasmoid.configuration.timer_repeats // New property to avoid checked=pressed theming.
					icon.name: isChecked ? 'media-playlist-repeat' : 'gtk-stop'
					text: topRow.contentsFit ? i18n("Repeat") : ""
					onClicked: {
						plasmoid.configuration.timer_repeats = !isChecked
					}

					PlasmaCore.ToolTipArea {
						anchors.fill: parent
						enabled: !topRow.contentsFit
						mainText: i18n("Repeat")
						location: PlasmaCore.Types.LeftEdge
					}
				}

				PlasmaComponents3.ToolButton {
					id: timerSfxEnabledButton
					readonly property bool isChecked: plasmoid.configuration.timer_sfx_enabled // New property to avoid checked=pressed theming.
					icon.name: isChecked ? 'audio-volume-high' : 'dialog-cancel'
					text: topRow.contentsFit ? i18n("Sound") : ""
					onClicked: {
						plasmoid.configuration.timer_sfx_enabled = !isChecked
					}

					PlasmaCore.ToolTipArea {
						anchors.fill: parent
						enabled: !topRow.contentsFit
						mainText: i18n("Sound")
						location: PlasmaCore.Types.LeftEdge
					}
				}
			}
			
		}

		RowLayout {
			id: bottomRow
			spacing: Math.floor(2 * units.devicePixelRatio)

			// onWidthChanged: console.log('row.width', width)

			Repeater {
				id: defaultTimerRepeater
				model: defaultTimers

				TimerPresetButton {
					text: durationShortFormat(modelData.seconds)
					onClicked: setDurationAndStart(modelData.seconds)
				}
			}

			function updatePresetVisibilities() {
				var availableWidth = timerButtonView.width
				var w = 0
				for (var i = 0; i < defaultTimerRepeater.count; i++) {
					var item = defaultTimerRepeater.itemAt(i)
					var itemWidth = item.width
					if (i > 0) {
						itemWidth += bottomRow.spacing
					}
					if (w + itemWidth <= availableWidth) {
						item.visible = true
					} else {
						item.visible = false
					}
					w += itemWidth
					// console.log('updatePresetVisibilities', i, item.Layout.minimumWidth, item.visible, itemWidth, availableWidth)
				}
			}
		}
	}

	Loader {
		id: setTimerViewLoader
		anchors.fill: parent
		source: "TimerInputView.qml"
		active: timerView.setTimerViewVisible
		opacity: timerView.setTimerViewVisible ? 1 : 0
		visible: opacity > 0
		Behavior on opacity {
			NumberAnimation { duration: 200 }
		}
	}


	Component.onCompleted: {
		timerView.forceActiveFocus()

		// Debug in qmlviewer
		if (typeof popup === 'undefined') {
			timerView.timerDuration = 3
			timerRepeats = true
			sfxEnabled = true
			timerTicker.start()
		}
	}

	Timer {
		id: timerTicker
		interval: 1000
		running: false
		repeat: true

		onTriggered: {
			timerView.timerSeconds -= 1
		}
	}

	function setDuration(duration) {
		if (duration <= 0) {
			return
		}
		timerDuration = duration
		timerSeconds = duration
	}

	function setDurationAndStart(duration) {
		setDuration(duration)
		if (duration > 0) {
			timerTicker.restart()
		}
	}

	onTimerDurationChanged: {
		timerSeconds = timerDuration
	}

	onTimerSecondsChanged: {
		// console.log('onTimerSecondsChanged', timerSeconds)
		timerLabel.text = formatTimer(timerSeconds)

		if (timerSeconds <= 0) {
			onTimerFinished()
		}
	}

	function formatTimer(nSeconds) {
		// returns "1:00:00" or "10:00" or "0:01"
		var hours = Math.floor(nSeconds / 3600)
		var minutes = Math.floor((nSeconds - hours*3600) / 60)
		var seconds = nSeconds - hours*3600 - minutes*60
		var s = "" + (seconds < 10 ? "0" : "") + seconds
		s = minutes + ":" + s
		if (hours > 0) {
			s = hours + ":" + (minutes < 10 ? "0" : "") + s
		}
		return s
	}

	function repeatTimer() {
		timerSeconds = timerDuration
		timerTicker.start()
	}

	function onTimerFinished() {
		timerTicker.stop()
		createNotification()

		if (timerRepeats) {
			repeatTimer()
		}
	}

	function createNotification() {
		var args = {
			appName: i18n("Timer"),
			appIcon: "chronometer",
			summary: i18n("Timer finished"),
			body: i18n("%1 has passed", formatTimer(timerDuration)),
			expireTimeout: 2000,
		}
		if (timerSfxEnabled) {
			args.soundFile = plasmoid.configuration.timer_sfx_filepath
		}

		args.actions = []
		if (!plasmoid.configuration.timer_repeats) {
			var action = 'repeat' + ',' + i18n("Repeat")
			args.actions.push(action)
		}
		notificationManager.notify(args, function(actionId){
			if (actionId == 'repeat') {
				repeatTimer()
			}
		})
	}


	// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmacomponents/qmenu.cpp
	// Example: https://github.com/KDE/plasma-desktop/blob/master/applets/taskmanager/package/contents/ui/ContextMenu.qml
	PlasmaComponents.ContextMenu {
		id: contextMenu

		function newSeperator() {
			return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu)
		}
		function newMenuItem() {
			return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu)
		}

		function loadDynamicActions() {
			contextMenu.clearMenuItems()

			// Repeat
			var menuItem = newMenuItem()
			menuItem.icon = plasmoid.configuration.timer_repeats ? 'media-playlist-repeat' : 'gtk-stop'
			menuItem.text = i18n("Repeat")
			menuItem.clicked.connect(function() {
				timerRepeatsButton.clicked()
			})
			contextMenu.addMenuItem(menuItem)

			// Sound
			var menuItem = newMenuItem()
			menuItem.icon = plasmoid.configuration.timer_sfx_enabled ? 'audio-volume-high' : 'gtk-stop'
			menuItem.text = i18n("Sound")
			menuItem.clicked.connect(function() {
				timerSfxEnabledButton.clicked()
			})
			contextMenu.addMenuItem(menuItem)

			//
			contextMenu.addMenuItem(newSeperator())

			// Set Timer
			var menuItem = newMenuItem()
			menuItem.icon = 'text-field'
			menuItem.text = i18n("Set Timer")
			menuItem.clicked.connect(function() {
				timerView.setTimerViewVisible = true
			})
			contextMenu.addMenuItem(menuItem)

			//
			contextMenu.addMenuItem(newSeperator())

			for (var i = 0; i < defaultTimers.length; i++) {
				var timerSeconds = defaultTimers[i].seconds

				var menuItem = newMenuItem()
				menuItem.icon = 'chronometer'
				menuItem.text = durationShortFormat(defaultTimers[i].seconds)
				menuItem.clicked.connect(timerView.setDurationAndStart.bind(timerView, defaultTimers[i].seconds))
				contextMenu.addMenuItem(menuItem)
			}

		}

		function show(x, y) {
			loadDynamicActions()
			open(x, y)
		}

		function showBelow(item) {
			visualParent = item
			placement = PlasmaCore.Types.BottomPosedLeftAlignedPopup
			loadDynamicActions()
			openRelative()
		}
	}
}
