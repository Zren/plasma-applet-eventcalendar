// Version 2

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.0 as Kirigami

GridLayout {
	id: configDimension
	columnSpacing: 0
	rowSpacing: 0

	property int orientation: Qt.Horizontal
	property color lineColor: "#000"
	property int lineThickness: 2 * Kirigami.Units.devicePixelRatio

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
			PropertyChanges { target: lineSpanA
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
				implicitHeight: configDimension.lineThickness
			}
			PropertyChanges { target: configSpinBox
				Layout.alignment: Qt.AlignVCenter
			}
			PropertyChanges { target: lineSpanB
				Layout.fillWidth: true
				Layout.alignment: Qt.AlignVCenter
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
			PropertyChanges { target: lineSpanA
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignHCenter
				implicitWidth: configDimension.lineThickness
			}
			PropertyChanges { target: configSpinBox
				Layout.alignment: Qt.AlignHCenter
			}
			PropertyChanges { target: lineSpanB
				Layout.fillHeight: true
				Layout.alignment: Qt.AlignHCenter
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
	Rectangle {
		id: lineSpanA
		color: configDimension.lineColor
	}
	ConfigSpinBox {
		id: configSpinBox
	}
	Rectangle {
		id: lineSpanB
		color: configDimension.lineColor
	}
	Rectangle {
		id: lineB
		color: configDimension.lineColor
	}
}
