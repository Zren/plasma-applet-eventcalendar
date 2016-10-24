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
		console.log(search.query)
		runnerModel.query = search.query
	}

	property var filters: []
	onFiltersChanged: {
		runnerModel.deleteWhenEmpty = !runnerModel.deleteWhenEmpty // runnerModel.clear()
		runnerModel.runners = filters
		runnerModel.query = search.query
		// debouncedRefresh.restart()
	}

	Kicker.RunnerModel {
		id: runnerModel

		appletInterface: plasmoid
		favoritesModel: rootModel.favoritesModel
		// mergeResults: true

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
}
