import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ListModel {
	id: resultModel

	signal refreshing()
	signal refreshed()

	function refresh() {
		refreshing()
		
		// console.log('resultModel.refresh')
		//--- populate list
		var resultList = [];
		for (var i = 0; i < runnerModel.count; i++){
			var runner = runnerModel.modelForRow(i);
			// console.log(i, runner, runner.runnerId, runner.name)
			for (var j = 0; j < runner.count; j++) {
				// RunnerMatchesModel.modelForRow is NOT implemented.
				// We need to use model.data(model.index(row, 0), role)
				// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/abstractmodel.cpp#L35
				// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/runnermatchesmodel.cpp#L54

				// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/actionlist.h#L30
				var DescriptionRole = Qt.UserRole + 1;
				var GroupRole = DescriptionRole + 1;
				var FavoriteIdRole = DescriptionRole + 2;
				var IsSeparatorRole = DescriptionRole + 3;
				var IsDropPlaceholderRole = DescriptionRole + 4;
				var IsParentRole = DescriptionRole + 5;
				var HasChildrenRole = DescriptionRole + 6;
				var HasActionListRole = DescriptionRole + 7;
				var ActionListRole = DescriptionRole + 8;
				var UrlRole = DescriptionRole + 9;

				var modelIndex = runner.index(j, 0);

				// ListView.append() doesn't like it when we have { key: [object] }.
				var url = runner.data(modelIndex, UrlRole);
				if (typeof url === 'object') {
					url = url.toString();
				}
				var icon = runner.data(modelIndex, Qt.DecorationRole);
				if (typeof icon === 'object') {
					icon = icon.toString();
				}

				var resultItem = {
					runnerIndex: i,
					runnerName: runner.name,
					runnerItemIndex: j,
					name: runner.data(modelIndex, Qt.DisplayRole),
					description: runner.data(modelIndex, DescriptionRole),
					icon: icon,
					url: url,
					favoriteId: runner.data(modelIndex, FavoriteIdRole),
					largeIcon: false, // for KickerListView
				};

				// console.log(resultItem.name, resultItem.url);
				// for (var x = 0; x < 10; x++) {
				// 	console.log('\t', typeof runner.data(runner.index(j, 0), DescriptionRole + x));
				// }
				// console.log(resultItem.name, Qt.DisplayRole, DescriptionRole, UrlRole)
				resultList.push(resultItem);
			}
		}

		if (config.searchResultsCustomSort) {
			//--- sort: runner relevance (English only)

			// We have to sort by .name instead of .runnerId because the later isn't exposed... anywhere. :/
			var runnerOrder = [
				//--- Single line action
				"Desktop Sessions", // sessions
				"Command Line", // shell
				"Locations", // locations (Open website)

				//--- Single line
				"Calculator", // calculator
				"Date and Time", // datetime

				//--- Small Lists
				"Control Audio Player", // audioplayercontrol
				"Unit Converter", // converter
				"Dictionary", // dictionary
				"Terminate Applications", // kill

				//--- Large Lists
				"Applications", // services
				"System Settings",
				"Places", // places
				"Windows", // windows
				"Bookmarks", // bookmarks
				"Recent Documents", // ? baloosearch ?
				"Windowed widgets", // windowedwidgets

				//--- ?
				"Desktop Search", // baloosearch
				"KWin", // kwin
				"Plasma Desktop Shell", // plasma-desktop
				"Power", // powerdevil
				"Spell Checker", // spellchecker
				"Web Shortcuts", // webshortcuts
			];

			resultList = resultList.sort(function(a, b) {
				var aOrder = runnerOrder.indexOf(a.runnerName);
				var bOrder = runnerOrder.indexOf(b.runnerName);
				if (aOrder == -1 && bOrder == -1) { // Neither really matters
					return 0;
				} else if (aOrder == -1) { // a doesn't matter
					return 1; // a should be placed after b
				} else if (bOrder == -1) { // b doesn't matter
					return -1; // a should be placed before b
				} else {
					return aOrder - bOrder;
				}
			});

			//--- sort: matches start
			function moveToTopOfRunner(queryLower) {
				// Scan in reverse so we preserve runnerOrder with multiple matches
				for (var i = resultList.length-1; i >= 0; i--) {
					var resultItem = resultList[i];
					if (resultItem.name.toLowerCase().indexOf(queryLower) == 0) {
						for (var j = i-1; j >= 0; j--) {
							// Scan (in reverse) for insertion point.
							if (resultList[j].runnerName != resultItem.runnerName) {
								resultList.splice(i, 1); // remove from old index
								resultList.splice(j, 0, resultItem); // insert at new index
								break;
							}
						}
						
					}
				}
			}
			var queryLower = search.query.toLowerCase();
			moveToTopOfRunner(queryLower)
			
			//--- sort: exact match
			function moveToTop(queryLower) {
				// Scan in reverse so we preserve runnerOrder with multiple matches
				for (var i = resultList.length-1; i >= 0; i--) {
					var resultItem = resultList[i];
					if (queryLower == resultItem.name.toLowerCase()) {
						resultList.splice(i, 1); // remove at index
						resultList.splice(0, 0, resultItem); // add to beginning
					}
				}
			}

			// sort: clementine (English only)
			// /usr/share/applications/clementine.desktop
			if (queryLower == 'play') {
				moveToTop('Play - Clementine'.toLowerCase())
			} else if (queryLower == 'play') {
				moveToTop('Pause - Clementine'.toLowerCase())
			} else if (queryLower == 'play') {
				moveToTop('Stop - Clementine'.toLowerCase())
			} else if (queryLower.indexOf('prev') == 0) { // Matches previous as well
				moveToTop('Previous - Clementine'.toLowerCase())
			} else if (queryLower == 'next') {
				moveToTop('Next - Clementine'.toLowerCase())
			}
		}

		//--- Make the (selected) first item bigger.
		if (resultList.length > 0) {
			resultList[0].largeIcon = true
		}

		//--- Reverse the model?
		if (plasmoid.configuration.searchResultsReversed) {
			resultList.reverse()
		}

		//--- apply model
		resultModel.clear();
		for (var i = 0; i < resultList.length; i++) {
			resultModel.append(resultList[i]);
		}

		// console.log(JSON.stringify(resultList, null, '\t'))

		//--- listen for changes
		for (var i = 0; i < runnerModel.count; i++){
			var runner = runnerModel.modelForRow(i);
			if (!runner.listenersBound) {
				runner.countChanged.connect(debouncedRefresh.logAndRestart)
				runner.dataChanged.connect(debouncedRefresh.logAndRestart)
				runner.listenersBound = true;
			}
		}

		refreshed()
	}

	function triggerIndex(index) {
		var model = resultModel.get(index)
		var runner = runnerModel.modelForRow(model.runnerIndex)
		runner.trigger(model.runnerItemIndex, "", null)
		itemTriggered()
	}
	
	signal itemTriggered()

	function hasActionList(index) {
		var DescriptionRole = Qt.UserRole + 1;
		var HasActionListRole = DescriptionRole + 7;

		var model = resultModel.get(index)
		var runner = runnerModel.modelForRow(model.runnerIndex)
		var modelIndex = runner.index(model.runnerItemIndex, 0)
		return runner.data(modelIndex, HasActionListRole)
	}

	function getActionList(index) {
		var DescriptionRole = Qt.UserRole + 1;
		var ActionListRole = DescriptionRole + 8;

		var model = resultModel.get(index)
		var runner = runnerModel.modelForRow(model.runnerIndex)
		var modelIndex = runner.index(model.runnerItemIndex, 0)
		return runner.data(modelIndex, ActionListRole)
	}

	function triggerIndexAction(index, actionId, actionArgument) {
		// kicker/code/tools.js triggerAction()
		var model = resultModel.get(index)
		var runner = runnerModel.modelForRow(model.runnerIndex)
		runner.trigger(model.runnerItemIndex, actionId, actionArgument)
		itemTriggered()

		// Note that Recent Documents actions do not work (in the search results) as of Plasma 5.8.4
		// https://bugs.kde.org/show_bug.cgi?id=373173
	}
}
