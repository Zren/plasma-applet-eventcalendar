import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker
import "../code/KickerTools.js" as KickerTools

Item {
	id: appsModel
	property alias rootModel: rootModel
	property alias allAppsModel: allAppsModel
	property alias powerActionsModel: powerActionsModel
	property alias favoritesModel: favoritesModel

	signal refreshing()
	signal refreshed()

	Kicker.RootModel {
		id: rootModel
		appNameFormat: 0 // plasmoid.configuration.appNameFormat
		flat: true // isDash ? true : plasmoid.configuration.limitDepth
		showSeparators: false // !isDash
		appletInterface: plasmoid

		showAllSubtree: true //isDash
		showRecentApps: true //plasmoid.configuration.showRecentApps
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

		onCountChanged: {
			// for (var i = 0; i < rootModel.count; i++) {
			// 	var listModel = rootModel.modelForRow(i);
			// 	if (listModel.description == 'KICKER_ALL_MODEL') {
			// 		logObj('rootModel[' + i + ']', listModel)
			// 		appsModel.allAppsList = listModel;
			// 		appsModel.refreshed()
			// 	}
			// }
			allAppsModel.refresh()
		}
			
		onRefreshed: {
			//--- Power
			var systemModel = rootModel.modelForRow(rootModel.count - 1)
			var systemList = []
			powerActionsModel.parseModel(systemList, systemModel)
			powerActionsModel.list = systemList;

			allAppsModel.refresh()
		}
	}

	Item {
		//--- Detect Changes
		// Changes aren't bubbled up to the RootModel, so we need to detect changes somehow.
		
		// Recent Apps
		Repeater {
			model: rootModel.count >= 0 ? rootModel.modelForRow(0) : []
			
			Item {
				Component.onCompleted: {
					debouncedRefresh.restart()
				}
			}
		}

		// All Apps
		Repeater { // A-Z
			model: rootModel.count >= 2 ? rootModel.modelForRow(1) : []

			Item {
				property var parentModel: rootModel.modelForRow(1).modelForRow(index)

				Repeater { // Aaa ... Azz (Apps)
					model: parentModel.hasChildren ? parentModel : []

					Item {
						Component.onCompleted: {
							// console.log('depth2', index, display, model)
							debouncedRefresh.restart()
						}
					}
				}

				// Component.onCompleted: {
				// 	console.log('depth1', index, display, model)
				// }
			}
		}

		Timer {
			id: debouncedRefresh
			interval: 100
			onTriggered: allAppsModel.refresh()
		}
		
		Connections {
			target: plasmoid.configuration
			onShowRecentAppsChanged: debouncedRefresh.restart()
		}
	}


	Kicker.FavoritesModel {
		id: favoritesModel

		Component.onCompleted: {
			// favorites = 'systemsettings.desktop,sublime-text.desktop,clementine.desktop,hexchat.desktop,virtualbox.desktop'.split(',')
			favorites = plasmoid.configuration.favoriteApps
		}

		onFavoritesChanged: {
			plasmoid.configuration.favoriteApps = favorites
		}

		// Connections {
		// 	target: plasmoid.configuration

		// 	onFavoriteAppsChanged: {
		// 		favoritesModel.favorites = plasmoid.configuration.favoriteApps
		// 	}
		// }

		signal triggerIndex(int index)
		onTriggerIndex: {
			favoritesModel.trigger(index, "", null)
		}

		// signal aboutToShowActionMenu(string favoriteId, variant actionMenu)
		// onAboutToShowActionMenu: {
		// 	// var actionList = (model.hasActionList != null) ? model.actionList : [];
		// 	KickerTools.fillActionMenu(actionMenu, [], favoritesModel, favoriteId);
		// }

		// signal actionTriggered(int index, string actionId, variant actionArgument)
		// onActionTriggered: {
		// 	KickerTools.triggerAction(favoritesModel, index, actionId, actionArgument);
		// }

		// function openActionMenu(visualParent, x, y) {
		// 	aboutToShowActionMenu(actionMenu);
		// 	actionMenu.visualParent = visualParent;
		// 	actionMenu.open(x, y);
		// }

		// ActionMenu {
		// 	id: actionMenu

		// 	onActionClicked: {
		// 		actionTriggered(actionId, actionArgument);
		// 	}
		// }
	}


	KickerListModel {
		id: powerActionsModel
		onItemTriggered: {
			console.log('powerActionsModel.onItemTriggered')
			plasmoid.expanded = false;
		}
	}
	
	KickerListModel {
		id: allAppsModel
		onItemTriggered: {
			console.log('allAppsModel.onItemTriggered')
			plasmoid.expanded = false;
		}

		function getRecentApps() {
			var recentAppList = [];

			//--- populate
			parseModel(recentAppList, rootModel.modelForRow(0));

			//--- filter
			recentAppList = recentAppList.filter(function(item){
				//--- filter kcmshell5 applications since they show up blank (undefined)
				if (typeof item.name === 'undefined') {
					return false;
				} else {
					return true;
				}
			});

			//--- first 5 items
			recentAppList = recentAppList.slice(0, 5);

			//--- section
			for (var i = 0; i < recentAppList.length; i++) {
				var item = recentAppList[i];
				item.sectionKey = i18n('Recent Apps');
			}

			return recentAppList;
		}

		function refresh() {
			refreshing()
			
			// console.log('resultModel.refresh')
			//--- populate list
			var appList = [];
			parseModel(appList, rootModel.modelForRow(1));

			//--- filter
			// var powerActionsList = [];
			// var sceneUrls = [];
			// appList = appList.filter(function(item){
			// 	//--- filter multiples
			// 	if (item.url) {
			// 		if (sceneUrls.indexOf(item.url) >= 0) {
			// 			return false;
			// 		} else {
			// 			sceneUrls.push(item.url);
			// 			return true;
			// 		}
			// 	} else {
			// 		return true;
			// 		//--- filter
			// 		// if (item.parentModel.toString().indexOf('SystemModel') >= 0) {
			// 		// 	// console.log(item.description, 'removed');
			// 		// 	powerActionsList.push(item);
			// 		// 	return false;
			// 		// } else {
			// 		// 	return true;
			// 		// }
			// 	}
			// });
			// powerActionsModel.list = powerActionsList; 

			//---
			for (var i = 0; i < appList.length; i++) {
				var item = appList[i];
				if (item.name) {
					var firstCharCode = item.name.charCodeAt(0);
					if (48 <= firstCharCode && firstCharCode <= 57) { // isDigit
						item.sectionKey = '0-9';
					} else {
						item.sectionKey = item.name.charAt(0).toUpperCase();
					}
				} else {
					item.sectionKey = '?';
				}
				// console.log(item.sectionKey, item.name)
			}

			//--- sort
			appList = appList.sort(function(a,b) {
				if (a.name && b.name) {
					return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
				} else {
					// console.log(a, b);
					return 0;
				}
			})

			//--- Recent Apps
			if (plasmoid.configuration.showRecentApps) {
				var recentAppList = getRecentApps();
				appList = recentAppList.concat(appList); // prepend
			}

			//--- Power
			// var systemModel = rootModel.modelForRow(rootModel.count - 1)
			// var systemList = []
			// parseModel(systemList, systemModel)
			// powerActionsModel.list = systemList;

			//--- apply model
			allAppsModel.list = appList;
			// allAppsModel.log();

			//--- listen for changes
			// for (var i = 0; i < runnerModel.count; i++){
			// 	var runner = runnerModel.modelForRow(i);
			// 	if (!runner.listenersBound) {
			// 		runner.countChanged.connect(debouncedRefresh.logAndRestart)
			// 		runner.dataChanged.connect(debouncedRefresh.logAndRestart)
			// 		runner.listenersBound = true;
			// 	}
			// }

			refreshed()
		}
	}

	function endsWidth(s, substr) {
		// console.log(s, s.indexOf(substr), s.length - substr.length - 1)
		return s.indexOf(substr) == s.length - substr.length
	}

	function launch(launcherName) {
		for (var i = 0; i < allAppsModel.count; i++) {
			var item = allAppsModel.get(i);
			if (item.url && endsWidth(item.url, '/' + launcherName + '.desktop')) {
				item.parentModel.trigger(item.indexInParent, "", null);
				break;
			}
		}
	}
}