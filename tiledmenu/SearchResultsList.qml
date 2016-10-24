import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ListView { // RunnerResultsList
	id: searchResultsList
	width: parent.width
	Layout.fillHeight: true
	clip: true
	cacheBuffer: 1000 // Don't unload when scrolling (prevent stutter)

	// snapMode: ListView.SnapToItem
	keyNavigationWraps: true
	// highlightMoveDuration: 100
	highlightMoveVelocity: -1

	model: []
	delegate: MenuListItem {}
	
	section.property: 'runnerName'
	section.criteria: ViewSection.FullString
	section.delegate: PlasmaComponents.Label {
		text: section
		font.bold: true
		font.pixelSize: 14
	}

	Connections {
		target: search.results
		onRefreshing: {
			searchResultsList.model = []
			// console.log('search.results.onRefreshed')
			searchResultsList.currentIndex = 0
		}
		onRefreshed: {
			// console.log('search.results.onRefreshed')
			searchResultsList.model = search.results
			searchResultsList.currentIndex = 0
		}
	}

	highlight: PlasmaComponents.Highlight {
		// anchors.fill: searchResults.currentItem;

		visible: searchResultsList.currentItem && !searchResultsList.currentItem.isSeparator
	}

}
