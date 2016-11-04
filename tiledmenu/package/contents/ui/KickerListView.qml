import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

ListView {
	id: listView
	width: parent.width
	Layout.fillHeight: true
	clip: true
	cacheBuffer: 1000 // Don't unload when scrolling (prevent stutter)

	// snapMode: ListView.SnapToItem
	keyNavigationWraps: true
	highlightMoveDuration: 0
	highlightResizeDuration: 0

	property bool showItemUrl: true
	property bool largeFirstItem: true

	section.delegate: PlasmaComponents.Label {
		text: section
		font.bold: true
		font.pointSize: 14
	}

	delegate: MenuListItem {}

	property var modelList: model ? model.list : []
	
	// currentIndex: 0
	// Connections {
	// 	target: appsModel.allAppsModel
	// 	onRefreshing: {
	// 		console.log('appsList.onRefreshing')
	// 		appsList.model = []
	// 		// console.log('search.results.onRefreshed')
	// 		appsList.currentIndex = 0
	// 	}
	// 	onRefreshed: {
	// 		console.log('appsList.onRefreshed')
	// 		// appsList.model = appsModel.allAppsList
	// 		appsList.model = appsModel.allAppsList
	// 		appsList.modelList = appsModel.allAppsList.list
	// 		appsList.currentIndex = 0
	// 	}
	// }

	highlight: PlasmaComponents.Highlight {
		visible: listView.currentItem && !listView.currentItem.isSeparator
	}

	// function triggerIndex(index) {
	// 	model.triggerIndex(index)
	// }
}
