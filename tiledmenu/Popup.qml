import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaCore.Dialog {
	id: popup
	visible: true
	y: widget.y - height

	// property var bottomItem: bottomMenu

	Row {
		// width: 888
		// width: childrenRect.width
		// height: childrenRect.height
		height: 620
		// anchors.fill: parent

		// PlasmaComponents.Label {
		// 	visible: false
		// 	text: ""
		// 	color: "#888"
		// 	maximumLineCount: 1
		// 	elide: Text.ElideRight
		// }

		SearchView {
			width: 60+430
			height: parent.height
		}

		FavouritesView {
			
		}
		
		
	}
}
