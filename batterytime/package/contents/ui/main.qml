import QtQuick 2.1
import QtQuick.Layouts 1.3
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponent
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
	id: widget

	// https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.h
	// https://github.com/KDE/plasma-workspace/blob/master/dataengines/powermanagement/powermanagementengine.cpp
	PlasmaCore.DataSource {
		id: pmSource
		engine: "powermanagement"
		connectedSources: sources // basicSourceNames == ["Battery", "AC Adapter", "Sleep States", "PowerDevil", "Inhibitions"]
		onSourceAdded: {
			// console.log('onSourceAdded', source)
			disconnectSource(source)
			connectSource(source)
		}
		onSourceRemoved: {
			disconnectSource(source)
		}

		function log() {
			for (var i = 0; i < pmSource.sources.length; i++) {
				var sourceName = pmSource.sources[i]
				var source = pmSource.data[sourceName]
				for (var key in source) {
					console.log('pmSource.data["'+sourceName+'"]["'+key+'"] =', source[key])
				}
			}
		}
	}

	function getData(sourceName, key, def) {
		var source = pmSource.data[sourceName]
		if (typeof source === 'undefined') {
			return def;
		} else {
			var value = source[key]
			if (typeof value === 'undefined') {
				return def;
			} else {
				return value;
			}
		}
	}

	readonly property bool pluggedIn: getData('AC Adapter', 'Plugged in', false)

	readonly property bool hasBattery: getData('Battery', 'Has Battery', false)
	readonly property bool hasCumulative: getData('Battery', 'Has Cumulative', false)
	// readonly property int remainingTime: getData('Battery', 'Remaining msec', 0)

	property string currentBatteryName: 'Battery'
	property bool currentBatteryIsPowerSuppy: getData(currentBatteryName, 'Is Power Supply', false)
	property string currentBatteryState: getData(currentBatteryName, 'State', false)
	property int currentBatteryRemainingTime: getData(currentBatteryName, 'Remaining msec', 0)
	property int currentBatteryPercent: getData(currentBatteryName, 'Percent', 100)
	// Capacity
	// Vendor
	// Product

	readonly property bool isLidPresent: getData('PowerDevil', 'Is Lid Present', false)
	readonly property bool triggersLidAction: getData('PowerDevil', 'Triggers Lid Action', false)

	readonly property bool isScreenBrightnessAvailable: getData('PowerDevil', 'Screen Brightness Available', false)
	readonly property int maxScreenBrightness: getData('PowerDevil', 'Maximum Screen Brightness', 0)
	readonly property int minScreenBrightness: (maxScreenBrightness > 100 ? 1 : 0)
	property int screenBrightness: getData('PowerDevil', 'Screen Brightness', maxScreenBrightness)

	readonly property bool isKeyboardBrightnessAvailable: getData('PowerDevil', 'Keyboard Brightness Available', false)

	// Debugging
	property bool testing: false
	// Timer {
	// 	interval: 3000
	// 	running: widget.testing
	// 	repeat: true
	// 	triggeredOnStart: false
	// 	onTriggered: {
	// 		console.log('-----', Date.now())
	// 		pmSource.log()
	// 	}
	// }
	Timer {
		interval: 1000
		running: widget.testing
		repeat: true
		onTriggered: {
			if (currentBatteryState == "Charging") {
				currentBatteryPercent += 10

				if (currentBatteryPercent >= 100) {
					currentBatteryState = "FullyCharged"
				}
			} else if (currentBatteryState == "FullyCharged") {
				currentBatteryState = "Discharging"
			} else if (currentBatteryState == "Discharging") {
				currentBatteryPercent -= 10

				if (currentBatteryPercent <= 0) {
					currentBatteryState = "Charging"
				}
			}
			currentBatteryRemainingTime = currentBatteryPercent * 60 * 1000
			console.log(currentBatteryState, currentBatteryPercent)
		}
	}
	Component.onCompleted: {
		if (testing) {
			currentBatteryState = "Charging"
			currentBatteryPercent = 80
			currentBatteryRemainingTime = 80 * 60 * 1000
		}
	}

	Item {
		id: config
		property int lowPowerPercent: 15
		property color lowPowerColor: '#e33'
	}

	property bool currentBatteryLowPower: currentBatteryPercent <= config.lowPowerPercent
	property color currentTextColor: {
		if (currentBatteryLowPower) {
			return config.lowPowerColor
		} else {
			return theme.textColor
		}
	}
	
	Plasmoid.compactRepresentation: Item {
		id: panelItem

		property int textHeight: Math.max(6, Math.min(panelItem.height, 16 * units.devicePixelRatio))
		// onTextHeightChanged: console.log('textHeight', textHeight)

		states: [
			State {
				name: "horizontal"
				when: plasmoid.formFactor == PlasmaCore.Types.Horizontal
				PropertyChanges {
					target: panelItem
					Layout.minimumWidth: gridLayout.implicitWidth
					Layout.preferredWidth: gridLayout.implicitWidth
				}
				PropertyChanges {
					target: gridLayout
					rows: 1
				}
				PropertyChanges {
					target: batteryIconContainer
					height: gridLayout.height
				}
				PropertyChanges {
					target: percentText
					height: gridLayout.height
				}
				PropertyChanges {
					target: timeLeftText
					height: gridLayout.height
				}
			},
			State {
				name: "vertical"
				when: plasmoid.formFactor == PlasmaCore.Types.Vertical
				PropertyChanges {
					target: panelItem
					Layout.minimumHeight: gridLayout.implicitHeight
					Layout.preferredHeight: gridLayout.implicitHeight
					textHeight: 12 * units.devicePixelRatio
				}
				PropertyChanges {
					target: gridLayout
					columns: 1
				}
				PropertyChanges {
					target: batteryIconContainer
					width: gridLayout.width
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
				}
				PropertyChanges {
					target: percentText
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
				}
				PropertyChanges {
					target: timeLeftText
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
				}
			},
			State {
				name: "desktop"
				when: plasmoid.location == PlasmaCore.Types.Floating
				PropertyChanges {
					target: panelItem
					textHeight: 12 * units.devicePixelRatio
				}
				PropertyChanges {
					target: batteryIconContainer
					width: gridLayout.width
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
				}
				PropertyChanges {
					target: percentText
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
					height: gridLayout.height
				}
				PropertyChanges {
					target: timeLeftText
					anchors.left: gridLayout.left
					anchors.right: gridLayout.right
					height: gridLayout.height
				}
			}
		]

		GridLayout {
			id: gridLayout
			anchors.fill: parent
			columnSpacing: 0
			rowSpacing: 0

			Item {
				id: batteryIconContainer
				width: 22
				height: 12

				BreezeBatteryIcon {
					id: batteryIcon
					width: Math.min(parent.width, 22 * units.devicePixelRatio)
					height: Math.min(parent.height, 12 * units.devicePixelRatio)
					anchors.centerIn: parent
					charging: currentBatteryState == "Charging"
					charge: currentBatteryPercent
				}
			}


			PlasmaComponent.Label {
				id: percentText
				// Layout.fillWidth: true
				text: {
					if (currentBatteryPercent > 0) {
						// return KCoreAddons.Format.formatDuration(remainingTime, KCoreAddons.FormatTypes.HideSeconds);
						return '' + currentBatteryPercent + '%'
					} else {
						return '100%';
					}
				}
				font.pointSize: -1
				font.pixelSize: panelItem.textHeight
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: currentTextColor
			}

			PlasmaComponent.Label {
				id: timeLeftText
				// Layout.fillWidth: true
				visible: true
				// visible: currentBatteryRemainingTime > 0
				text: {
					if (currentBatteryRemainingTime > 0) {
						if (true) {
							return '' + Math.floor(currentBatteryRemainingTime / (60 * 1000)) + 'm'
						} else {
							return KCoreAddons.Format.formatDuration(currentBatteryRemainingTime, KCoreAddons.FormatTypes.HideSeconds)
						}
					} else {
						return '∞';
					}
				}
				font.pointSize: -1
				font.pixelSize: panelItem.textHeight
				fontSizeMode: Text.Fit
				horizontalAlignment: Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				color: currentTextColor
			}
		}
	}

	
}
