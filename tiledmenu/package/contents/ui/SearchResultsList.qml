import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

KickerListView { // RunnerResultsList
	id: searchResultsList

	model: []
	delegate: MenuListItem {
		property var runner: search.runnerModel.modelForRow(model.runnerIndex)
		iconSource: runner && runner.data(runner.index(model.runnerItemIndex, 0), Qt.DecorationRole)
	}
	
	section.property: 'runnerName'
	section.criteria: ViewSection.FullString
	// verticalLayoutDirection: config.searchResultsDirection

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
			// if (searchResultsList.verticalLayoutDirection == Qt.BottomToTop) {
			if (plasmoid.configuration.searchResultsReversed) {
				searchResultsList.currentIndex = searchResultsList.model.count - 1
			} else { // TopToBottom (normal)
				searchResultsList.currentIndex = 0
			}
		}
	}

}
