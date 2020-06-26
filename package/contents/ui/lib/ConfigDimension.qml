// Version 1

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

GridLayout {
	id: configDimension
	columnSpacing: 0
	rowSpacing: 0

	property int orientation: Qt.Horizontal
	property color lineColor: "#000"
	property int lineThickness: 2 * units.devicePixelRatio

	property alias configKey: configSpinBox.configKey
	property alias configValue: configSpinBox.configValue
	property alias horizontalAlignment: configSpinBox.horizontalAlignment
	property alias maximumValue: configSpinBox.maximumValue
	property alias minimumValue: configSpinBox.minimumValue
	property alias prefix: configSpinBox.prefix
	property alias stepSize: configSpinBox.stepSize
	property alias suffix: configSpinBox.suffix
	property alias value: configSpinBox.value

	property alias before: configSpinBox.before
	property alias after: configSpinBox.after

	states: [
		State {
			name: "horizontal"
			when: orientation == Qt.Horizontal

			PropertyChanges { target: configDimension
				rows: 1
			}
			PropertyChanges { target: lineA
				implicitWidth: configDimension.lineThickness
				Layout.fillHeight: true
			}
			PropertyChanges { target: centerArea
				Layout.fillWidth: true
			}
			AnchorChanges { target: lineSpan
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
			}
			PropertyChanges { target: lineSpan
				implicitHeight: configDimension.lineThickness
			}
			PropertyChanges { target: lineB
				implicitWidth: configDimension.lineThickness
				Layout.fillHeight: true
			}
		}
		, State {
			name: "vertical"
			when: orientation == Qt.Vertical

			PropertyChanges { target: configDimension
				columns: 1
			}
			PropertyChanges { target: lineA
				Layout.alignment: Qt.AlignHCenter
				implicitHeight: configDimension.lineThickness
				implicitWidth: configSpinBox.implicitHeight
			}
			PropertyChanges { target: centerArea
				Layout.fillHeight: true
			}
			AnchorChanges { target: lineSpan
				anchors.top: parent.top
				anchors.bottom: parent.bottom
				anchors.horizontalCenter: parent.horizontalCenter
			}
			PropertyChanges { target: lineSpan
				implicitWidth: configDimension.lineThickness
			}
			PropertyChanges { target: lineB
				Layout.alignment: Qt.AlignHCenter
				implicitHeight: configDimension.lineThickness
				implicitWidth: configSpinBox.implicitHeight
			}
		}
	]

	Rectangle {
		id: lineA
		color: configDimension.lineColor
	}
	Item {
		id: centerArea
		implicitWidth: configSpinBox.implicitWidth
		implicitHeight: configSpinBox.implicitHeight

		Rectangle {
			id: lineSpan
			color: configDimension.lineColor
		}

		ConfigSpinBox {
			id: configSpinBox
			anchors.centerIn: parent
		}
	}
	Rectangle {
		id: lineB
		color: configDimension.lineColor
	}
}
