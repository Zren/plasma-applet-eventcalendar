import QtQuick 2.0
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.0 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

Item {
	id: timerView

	property bool isSetTimerViewVisible: false

	implicitHeight: timerButtonView.height

	ColumnLayout {
		id: timerButtonView
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 4
		opacity: timerView.isSetTimerViewVisible ? 0 : 1
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
					if (timerModel.secondsLeft == 0) {
						return 'chronometer'
					} else if (timerModel.running) {
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
					if (timerModel.secondsLeft > 0) {
						if (timerModel.running) {
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
					if (timerModel.running) {
						timerModel.pause()
					} else if (timerModel.secondsLeft > 0) {
						timerModel.runTimer()
					} else { // timerModel.secondsLeft == 0
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
							timerModel.increaseDuration()
							timerModel.pause()
						} else if (delta < 0) {
							timerModel.decreaseDuration()
							timerModel.pause()
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
					readonly property bool isChecked: plasmoid.configuration.timerRepeats // New property to avoid checked=pressed theming.
					icon.name: isChecked ? 'media-playlist-repeat' : 'gtk-stop'
					text: topRow.contentsFit ? i18n("Repeat") : ""
					onClicked: {
						plasmoid.configuration.timerRepeats = !isChecked
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
					readonly property bool isChecked: plasmoid.configuration.timerSfxEnabled // New property to avoid checked=pressed theming.
					icon.name: isChecked ? 'audio-volume-high' : 'dialog-cancel'
					text: topRow.contentsFit ? i18n("Sound") : ""
					onClicked: {
						plasmoid.configuration.timerSfxEnabled = !isChecked
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
				model: timerModel.defaultTimers

				TimerPresetButton {
					text: timerModel.durationShortFormat(modelData.seconds)
					onClicked: timerModel.setDurationAndStart(modelData.seconds)
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
		active: timerView.isSetTimerViewVisible
		opacity: timerView.isSetTimerViewVisible ? 1 : 0
		visible: opacity > 0
		Behavior on opacity {
			NumberAnimation { duration: 200 }
		}
	}


	Component.onCompleted: {
		timerView.forceActiveFocus()
	}

	Connections {
		target: timerModel
		onSecondsLeftChanged: {
			timerLabel.text = timerModel.formatTimer(timerModel.secondsLeft)
		}
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
			menuItem.icon = plasmoid.configuration.timerRepeats ? 'media-playlist-repeat' : 'gtk-stop'
			menuItem.text = i18n("Repeat")
			menuItem.clicked.connect(function() {
				timerRepeatsButton.clicked()
			})
			contextMenu.addMenuItem(menuItem)

			// Sound
			var menuItem = newMenuItem()
			menuItem.icon = plasmoid.configuration.timerSfxEnabled ? 'audio-volume-high' : 'gtk-stop'
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
				timerView.isSetTimerViewVisible = true
			})
			contextMenu.addMenuItem(menuItem)

			//
			contextMenu.addMenuItem(newSeperator())

			for (var i = 0; i < timerModel.defaultTimers.length; i++) {
				var presetItem = timerModel.defaultTimers[i]

				var menuItem = newMenuItem()
				menuItem.icon = 'chronometer'
				menuItem.text = timerModel.durationShortFormat(presetItem.seconds)
				menuItem.clicked.connect(timerModel.setDurationAndStart.bind(timerModel, presetItem.seconds))
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
