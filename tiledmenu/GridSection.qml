import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0

ColumnLayout {
	width: 48 * 6 + 4 * 5

	PlasmaComponents.Label {
		text: "Title"
	}

	GridLayout {
		Layout.alignment: Qt.AlignTop | Qt.AlignLeft
		// Layout.fillHeight: true

		columns: 6


		rowSpacing: 4
		columnSpacing: 4

		

		Repeater {
			model: [
				0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0,
				0, 0, 0, 0, 0, 0,
			]

			delegate: Rectangle {
				width: 48
				height: 48

				DropArea {
					anchors.fill: parent
				}

				DragArea {
					anchors.fill: parent
					delegate: parent
					mimeData {
						source: parent
					}
				}
			}
		}
		
	}
}