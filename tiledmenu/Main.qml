import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker

PlasmaCore.Dialog {
	id: widget
	x: 0
	y: Screen.desktopAvailableHeight - height
	width: 360
	height: 48

	property bool expanded: true //false

	Item {
		id: search
		property string query: ""
		property bool isSearching: query.length > 0
		onQueryChanged: {
			console.log(search.query)
			runnerModel.query = search.query
		}
	}


	function logListModel(label, listModel) {
		console.log(label + '.count', listModel.count);
		// logObj(label, listModel);
		for (var i = 0; i < listModel.count; i++) {
			var item = listModel.modelForRow(i);
			var itemLabel = label + '[' + i + ']';
			console.log(itemLabel, item);
			logObj(itemLabel, item);
			if (('' + item).indexOf('Model') >= 0) {
				logListModel(itemLabel, item);
			}
		}
	}
	function logObj(label, obj) {
		// if (obj && typeof obj === 'object') {
		// 	console.log(label, Object.keys(obj))
		// }
		
		for (var key in obj) {
			var val = obj[key];
			if (typeof val !== 'function') {
				var itemLabel = label + '.' + key;
				console.log(itemLabel, typeof val, val);
				if (('' + val).indexOf('Model') >= 0) {
					logListModel(itemLabel, val);
				}
			}
		}
	}

	Item {
		Item {
			id: plasmoid
			property var configuration: Item {}
		}

		Kicker.RootModel {
			id: rootModel
			appNameFormat: 1 // plasmoid.configuration.appNameFormat
			flat: false // isDash ? true : plasmoid.configuration.limitDepth
			showSeparators: false // !isDash
			appletInterface: plasmoid

			showAllSubtree: false //isDash
			showRecentApps: false //plasmoid.configuration.showRecentApps
			showRecentDocs: false //plasmoid.configuration.showRecentDocs
			showRecentContacts: false //plasmoid.configuration.showRecentContacts


			function log() {
				// logListModel('rootModel', rootModel);
				var listModel = rootModel;
				for (var i = 0; i < listModel.count; i++) {
					var item = listModel.modelForRow(i);
					// console.log(listModel, i, item);
					logObj('rootModel[' + i + ']', item)
					// logListModel('rootModel[' + i + ']', item);
				}
			}

			onDataChanged: {
				if (count >= 2) {
					
				}
			}
		}

		Kicker.RunnerModel {
			id: runnerModel

			appletInterface: plasmoid
			favoritesModel: rootModel.favoritesModel
			// mergeResults: true

			runners: {
				// var runners = new Array("services");
				var runners = [
					// Full list: ls /usr/share/kservices5/ | grep plasma-runner-*
					"activityrunner",
					"audioplayercontrol_config",
					"audioplayercontrol", // Doesn't work
					"baloosearch",
					"bookmarks", // Works
					"calculator", // Works
					"converter", 
					"datetime", // Doesn't work
					"dictionary_config",
					"dictionary", // Doesn't work
					"kill_config",
					"kill",
					"kwin",
					"locations",
					"places", // Works
					"plasma-desktop",
					"powerdevil",
					"services", // (aka Apps) Works
					"sessions", // Doesn't work
					"shell", // Works
						// trigger() = TERM environment variable not set.
					"spellchecker_config",
					"spellchecker",
					"webshortcuts",
					"windowedwidgets", // Doesn't work
					"windows", // Works

					//--- default kicker
					// "services",
					// "desktopsessions",
					// "PowerDevil",
					// "bookmarks",
					// "baloosearch",
				];

				// if (isDash) {
					// runners = runners.concat(new Array("desktopsessions", "PowerDevil"));
				// }

				// if (plasmoid.configuration.useExtraRunners) {
				// 	runners = runners.concat(plasmoid.configuration.extraRunners);
				// }

				return null;
			}

			// deleteWhenEmpty: isDash
			deleteWhenEmpty: false

			onDataChanged: debouncedRefresh.restart()
			onCountChanged: debouncedRefresh.restart()
		}

		Timer {
			id: debouncedRefresh
			interval: 100
			onTriggered: resultModel.refresh()

			function logAndRestart() {
				console.log('debouncedRefresh')
				restart()
			}
		}
		ListModel {
			id: resultModel

			signal refreshed()

			function refresh() {
				console.log('resultModel.refresh')
				//--- populate list
				var resultList = [];
				for (var i = 0; i < runnerModel.count; i++){
					var runner = runnerModel.modelForRow(i);
					console.log(i, runner, runner.runnerId, runner.name)
					for (var j = 0; j < runner.count; j++) {

						// RunnerMatchesModel.modelForRow is NOT implemented.
						// We need to use model.data(model.index(row, 0), role)
						// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/abstractmodel.cpp#L35
						// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/runnermatchesmodel.cpp#L54
						var resultItem = {
							runnerIndex: i,
							runnerName: runner.name,
							runnerItemIndex: j,
							name: runner.data(runner.index(j, 0), Qt.DisplayRole),
							description: runner.data(runner.index(j, 0), Kicker.DescriptionRole),
							icon: runner.data(runner.index(j, 0), Qt.DecorationRole),
							url: runner.data(runner.index(j, 0), Kicker.UrlRole),
							// Kicker.FavoriteIdRole
							// Kicker.HasActionListRole
							// Kicker.ActionListRole
						};
						resultList.push(resultItem);
					}
				}

				//--- sort: runner relevance

				// We have to sort by .name instead of .runnerId because the later isn't exposed... anywhere. :/
				var runnerOrder = [
					//--- Single line action
					"Desktop Sessions", // sessions
					"Command Line", // shell

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
					"Locations", // locations
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

				//--- sort: exact match
				// Scan in reverse so we preserve runnerOrder with multiple matches
				for (var i = resultList.length-1; i >= 0; i--) {
					var resultItem = resultList[i];
					if (resultItem.name.toLowerCase() == search.query.toLowerCase()) {
						resultList.splice(i, 1); // remove at index
						resultList.splice(0, 0, resultItem); // add to beginning
					}
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
		}

		Kicker.DragHelper {
			id: dragHelper

			dragIconSize: units.iconSizes.medium
		}

		Kicker.ProcessRunner {
			id: processRunner
		}

		Kicker.WindowSystem {
			id: windowSystem
		}
	}


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
				onClicked: {
					widget.expanded = !widget.expanded;
					// rootModel.log();
				}
			}
		}
		
		Popup {
			id: popup
			visible: widget.expanded

			// visible: true
		}
	}

	Component.onCompleted: {
		// rootModel.refresh();
		// rootModel.log();

		// https://userbase.kde.org/Plasma/Krunner
		search.query = "google"
	}
}
