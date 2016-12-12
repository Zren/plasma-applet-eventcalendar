import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

PlasmaComponents.ToolButton {
	id: flatButton
	width: parent.width
	height: config.flatButtonSize
	iconName: ""
	property bool expanded: true
	text: ""
	property string label: expanded ? text : ""
	property bool labelVisible: text != ""
	property color backgroundColor: "transparent"
	property bool zoomOnPush: true

	// http://doc.qt.io/qt-5/qt.html#Edge-enum
	property int checkedEdge: 0 // 0 = all edges
	property int checkedEdgeWidth: 2 * units.devicePixelRatio

	style: PlasmaStyles.ToolButtonStyle {
		label: RowLayout {
			spacing: units.smallSpacing
			scale: control.zoomOnPush && control.pressed ? (height-5) / height : 1
			Behavior on scale { NumberAnimation { duration: 200 } }

			Item {
				Layout.fillHeight: true
				Layout.preferredWidth: height
				visible: control.iconName

				PlasmaCore.IconItem {
					id: icon
					source: control.iconName || control.iconSource
					width: config.flatButtonIconSize
					height: config.flatButtonIconSize
					anchors.centerIn: parent
					// colorGroup: PlasmaCore.Theme.ButtonColorGroup
				}
			}

			PlasmaComponents.Label {
				id: label
				text: QtQuickControlsPrivate.StyleHelpers.stylizeMnemonics(control.text)
				font: control.font || theme.defaultFont
				visible: control.labelVisible
				horizontalAlignment: Text.AlignLeft
				verticalAlignment: Text.AlignVCenter
				Layout.fillWidth: true
			}
		}

		background: Item {
			Rectangle {
				id: background
				anchors.fill: parent
				color: flatButton.backgroundColor
			}

			Rectangle {
				id: checkedOutline
				color: theme.highlightColor
				visible: control.checked
				anchors.left: parent.left
				anchors.top: parent.top
				anchors.right: parent.right
				anchors.bottom: parent.bottom

				states: [
					State {
						when: control.checkedEdge === 0
						PropertyChanges {
							target: checkedOutline
							anchors.fill: checkedOutline.parent
							color: "transparent"
							border.color: theme.highlightColor
						}
					},
					State {
						when: control.checkedEdge == Qt.TopEdge
						PropertyChanges {
							target: checkedOutline
							anchors.bottom: undefined
							height: control.checkedEdgeWidth
						}
					},
					State {
						when: control.checkedEdge == Qt.LeftEdge
						PropertyChanges {
							target: checkedOutline
							anchors.right: undefined
							width: control.checkedEdgeWidth
						}
					},
					State {
						when: control.checkedEdge == Qt.RightEdge
						PropertyChanges {
							target: checkedOutline
							anchors.left: undefined
							width: control.checkedEdgeWidth
						}
					},
					State {
						when: control.checkedEdge == Qt.BottomEdge
						PropertyChanges {
							target: checkedOutline
							anchors.top: undefined
							height: control.checkedEdgeWidth
						}
					}
				]
			}

			states: [
				State {
					name: "hovering"
					when: !control.pressed && control.hovered
					PropertyChanges {
						target: background
						color: theme.buttonBackgroundColor
					}
				},
				State {
					name: "pressed"
					when: control.pressed
					PropertyChanges {
						target: background
						color: theme.highlightColor
					}
				}
			]

			transitions: [
				Transition {
					to: "hovering"
					ColorAnimation { duration: 200 }
				},
				Transition {
					to: "pressed"
					ColorAnimation { duration: 100 }
				}
			]
		}
	}
}