import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.Dialog {
	id: widget
	x: 0
	y: Screen.desktopAvailableHeight - height
	width: 360
	height: 48

	Item {

		anchors.margins: 10
		width: 360
		height: 38

		RowLayout {
			anchors.fill: parent
			spacing: 0
			LauncherIcon {
				iconSource: "start-here-kde"
				iconSize: 24
				width: 48
				Layout.fillHeight: true
				// backgroundColor: "#222"
			}

			// TextField {
			// 	placeholderText: "Search"
			// 	Layout.fillWidth: true
			// 	Layout.fillHeight: true
			// 	style: TextFieldStyle {
			// 		background: Rectangle {
			// 			color: "#eee"
			// 		}
			// 	}
			// }
		}

		
		PlasmaCore.Dialog {
			id: popup
			visible: true
			y: widget.y - height

			Menu1 {
				width: 888
				height: 600
				// anchors.fill: parent
			}
		}
	}
}