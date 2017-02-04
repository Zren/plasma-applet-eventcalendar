import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
	id: search
	property alias results: resultModel
	property alias runnerModel: runnerModel

	property string query: ""
	property bool isSearching: query.length > 0
	onQueryChanged: {
		runnerModel.query = search.query
	}

	// KRunner runners are defined in /usr/share/kservices5/plasma-runner-*.desktop
	// To list the runner ids, use:
	//     find /usr/share/kservices5/ -iname "plasma-runner-*.desktop" -print0 | xargs -0 grep "PluginInfo-Name" | sort
	property var filters: []
	onFiltersChanged: {
		runnerModel.deleteWhenEmpty = !runnerModel.deleteWhenEmpty // runnerModel.clear()
		runnerModel.runners = filters
		runnerModel.query = search.query
	}

	Kicker.RunnerModel {
		id: runnerModel

		appletInterface: plasmoid
		favoritesModel: rootModel.favoritesModel
		mergeResults: config.searchResultsMerged

		runners: [] // Empty = All runners.

		// deleteWhenEmpty: isDash
		// deleteWhenEmpty: false

		onRunnersChanged: debouncedRefresh.restart()
		onDataChanged: debouncedRefresh.restart()
		onCountChanged: debouncedRefresh.restart()
	}

	Timer {
		id: debouncedRefresh
		interval: 100
		onTriggered: resultModel.refresh()

		function logAndRestart() {
			// console.log('debouncedRefresh')
			restart()
		}
	}

	SearchResultsModel {
		id: resultModel
	}

	property var defaultFilters: [
		'Dictionary',
		'services',
		// 'calculator',
		'shell',
		'org.kde.windowedwidgets',
		'org.kde.datetime',
		'baloosearch',
		// 'bookmarks',
		'locations',
		'unitconverter',
	]

	function isFilter(runnerId) {
		return filters.length == 1 && filters[0] == runnerId
	}
	property bool isDefaultFilter: filters == defaultFilters
	property bool isAppsFilter: isFilter('services')
	property bool isFileFilter: isFilter('baloosearch')
	property bool isBookmarksFilter: isFilter('bookmarks')

	function applyDefaultFilters() {
		filters = defaultFilters
	}
}
