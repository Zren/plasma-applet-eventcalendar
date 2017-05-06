import QtQuick 2.5
import QtQuick.Layouts 1.3
import QtQuick.Window 2.1
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles
import QtMultimedia 5.6
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

PlasmaComponents.Slider {
	id: slider
	anchors.fill: parent
	orientation: Qt.Vertical
	tickmarksEnabled: true
	property real hundredPercentValue: 65536
	maximumValue: hundredPercentValue * 1.05
	property bool isVolumeBoosted: value > hundredPercentValue // 100% is 65863.68, not 65536... Bleh. Just trigger at a round number.
	property bool isBoostable: maximumValue > hundredPercentValue
	readonly property int percentage: Math.round(value / hundredPercentValue * 100)
	readonly property int maxPercentage: Math.ceil(maximumValue / hundredPercentValue * 100)

	property bool showVisualFeedback: config.showVisualFeedback
	readonly property bool isPeaking: volumePeakLoader.active && volumePeakLoader.item
	readonly property real peakValue: isPeaking ? volumePeakLoader.item.defaultSinkPeak : 65536
	readonly property real peakRatio: peakValue / 65536
	Loader {
		id: volumePeakLoader
		property bool validType: mixerItem.mixerItemType === 'Sink' || mixerItem.mixerItemType === 'Source' // || mixerItem.mixerItemType === 'SourceOutput'
		active: showVisualFeedback && validType
		source: "VolumePeaksManager.qml"
	}

	// Component.onCompleted: {
	// 	console.log('maxPercentage', maxPercentage)
	// 	console.log(Math.floor(maxPercentage / 10) + 1)
	// }

	property int grooveThickness: 5 * units.devicePixelRatio
	// property int handleHeight: 20 * units.devicePixelRatio

	property string svgUrl: config.volumeSliderUrl
	PlasmaCore.Svg {
		id: grooveSvg
		imagePath: slider.svgUrl
		colorGroup: PlasmaCore.ColorScope.colorGroup
	}

	property alias handleHeight: handleSize.naturalSize.height
	PlasmaCore.SvgItem {
		id: handleSize
		anchors.fill: parent
		svg: grooveSvg
		elementId: "vertical-slider-handle"
		visible: false
	}

	// http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/SliderStyle_8qml_source.html
	style: PlasmaStyles.SliderStyle {
		id: style

		property int numTicks: Math.ceil(control.maxPercentage / 10) + 1 // 0% .. 100% by 10 = 11 ticks (or ...150% = 16 ticks)
		property real tickAvailableHeight: (control.width - control.grooveThickness) / 2
		
		function calcTickWidth(tickIndex) {
			if (tickIndex == 0) {
				return 0 // 0% has no tick
			} else if (tickIndex % 5 == 0) {
				// 50%, 100%, 150% have medium length ticks
				// 50%: 2/10
				// 100%: 3/10
				// 150%: 4/10
				// >=200%: 5/10
				return tickAvailableHeight*(1+Math.min(tickIndex/5, 4))/5
			} else {
				return tickAvailableHeight*1/5 // 10%, 20%, ... have short ticks
			}
		}

		handle: Item {
			width: handle.naturalSize.width
			height: handle.naturalSize.height
			PlasmaCore.SvgItem {
				id: handle
				anchors.fill: parent
				svg: grooveSvg
				elementId: "vertical-slider-handle"
			}
			PlasmaComponents.Label {
				text: control.percentage
				anchors.horizontalCenter: handle.horizontalCenter
				anchors.bottom: handle.top
				rotation: control.orientation == Qt.Vertical ? 90 : 0
			}
		}

		groove: Item {
			id: grooveItem
			anchors.fill: parent

			property real valuePosition: styleData.handlePosition - control.handleHeight/2
			property real peakPosition: valuePosition * control.peakRatio

			PlasmaCore.FrameSvgItem {
				id: groove
				imagePath: slider.svgUrl
				prefix: "groove"
				// height: 15
				height: control.grooveThickness
				colorGroup: PlasmaCore.ColorScope.colorGroup
				opacity: control.enabled ? 1 : 0.6
				// anchors.fill: parent
				// anchors.fill: parent

				anchors.leftMargin: control.handleHeight / 2
				anchors.rightMargin: control.handleHeight - control.handleHeight / 2
				// width: parent.width - styleData.handleWidth
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter

				PlasmaCore.FrameSvgItem {
					id: highlight
					imagePath: slider.svgUrl
					prefix: control.percentage <= 100 ? "groove-highlight" : "groove-danger"
					height: groove.height
					width: grooveItem.valuePosition
					visible: width > 0
					anchors.verticalCenter: parent.verticalCenter
					colorGroup: PlasmaCore.ColorScope.colorGroup
				}

				PlasmaCore.FrameSvgItem {
					id: peakHighlight
					imagePath: slider.svgUrl
					prefix: "groove-peaking"
					height: groove.height
					width: grooveItem.peakPosition
					visible: control.isPeaking && width > 0
					anchors.verticalCenter: parent.verticalCenter
					colorGroup: PlasmaCore.ColorScope.colorGroup
				}

				PlasmaCore.SvgItem {
					id: grooveTriangle
					svg: grooveSvg
					elementId: "groove-triangle"
					height: style.calcTickWidth(style.numTicks - 1)
					anchors.left: parent.left
					anchors.top: groove.bottom
					anchors.right: parent.right

					Item {
						height: grooveTriangle.height
						width: grooveItem.valuePosition
						clip: true

						PlasmaCore.SvgItem {
							id: grooveHighlightTriangle
							svg: grooveSvg
							elementId: control.percentage <= 100 ? "groove-highlight-triangle" : "groove-danger-triangle"
							height: grooveTriangle.height
							width: grooveTriangle.width
							visible: control.value > 0
						}
					}

					Item {
						height: grooveTriangle.height
						width: grooveItem.peakPosition
						clip: true

						PlasmaCore.SvgItem {
							id: groovePeakHighlightTriangle
							svg: grooveSvg
							elementId: "groove-peaking-triangle"
							height: grooveTriangle.height
							width: grooveTriangle.width
							visible: control.isPeaking && control.value > 0
						}
					}

				}
			}
		}

		tickmarks: Repeater {
			// width/height and x/y is reversed since it's Vertical

			id: repeater
			model: style.numTicks
			// onModelChanged: console.log('model', model)
			// model: slider.tickmarkModel
			// width: control.height 
			// height: control.width
			anchors.fill: parent

			Rectangle {
				function setAlpha(c, a) {
					var c2 = Qt.darker(c, 1)
					c2.a = a
					return c2
				}
				color: theme.textColor == theme.buttonBackgroundColor ? theme.backgroundColor : setAlpha(theme.textColor, 0.3)
				// opacity: 0.2
				// border.width: 1
				// border.color: theme.backgroundColor
				// width: 3
				width: 1
				height: style.calcTickWidth(index)
				y: control.width / 2 + control.grooveThickness / 2
				x: {
					// if (index == 0) { // Align tick at very bottom to it's bottom.
					// 	return 0
					// } else if (index == repeater.count-1) { // Align tick at very top to it's top.
					// 	return repeater.width - width
					// } else {
						//Position ticklines from styleData.handleWidth to width - styleData.handleWidth/2
						//position them at an half handle width increment
						return styleData.handleWidth / 2 + index * ((control.height - styleData.handleWidth) / (repeater.count>1 ? repeater.count-1 : 1)) - 1
					// }
				}

			}
		}
	}
}