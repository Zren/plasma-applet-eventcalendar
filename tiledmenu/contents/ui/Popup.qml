import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	// Layout.preferredWidth: 888
	// Layout.preferredHeight: 620

	// width: childrenRect.width
	// height: childrenRect.height

	property alias searchView: searchView
	property alias favouritesView: favouritesView

	Row {
		// width: 888
		// width: childrenRect.width
		// height: childrenRect.height
		// height: 620
		anchors.fill: parent

		// PlasmaComponents.Label {
		// 	visible: false
		// 	text: ""
		// 	color: "#888"
		// 	maximumLineCount: 1
		// 	elide: Text.ElideRight
		// }

		SearchView {
			id: searchView
			width: 60+430
			height: parent.height
		}

		FavouritesView {
			id: favouritesView
			width: parent.width - searchView.width
			height: parent.height
		}
		
	}
}
