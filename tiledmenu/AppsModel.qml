import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
	id: appsModel
	property alias rootModel: rootModel
	property alias allAppsModel: allAppsModel
	property alias powerActionsModel: powerActionsModel

	signal refreshing()
	signal refreshed()

	Kicker.RootModel {
		id: rootModel
		appNameFormat: 0 // plasmoid.configuration.appNameFormat
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
	}


	KickerListModel {
		id: powerActionsModel
		onItemTriggered: {
			console.log('powerActionsModel.onItemTriggered')
			widget.expanded = false;
		}
	}
	
	KickerListModel {
		id: allAppsModel
		onItemTriggered: {
			console.log('allAppsModel.onItemTriggered')
			widget.expanded = false;
		}

		function refresh() {
			refreshing()
			
			// console.log('resultModel.refresh')
			//--- populate list
			var appList = [];
			parseModel(appList, rootModel);

			//--- filter
			var powerActionsList = [];
			var sceneUrls = [];
			appList = appList.filter(function(item){
				//--- filter multiples
				if (item.url) {
					if (sceneUrls.indexOf(item.url) >= 0) {
						return false;
					} else {
						sceneUrls.push(item.url);
						return true;
					}
				} else {
					//--- filter
					if (item.parentModel.toString().indexOf('SystemModel') >= 0) {
						console.log(item.description, 'removed');
						powerActionsList.push(item);
						return false;
					} else {
						return true;
					}
				}
			});
			powerActionsModel.list = powerActionsList;

			//---
			// for (var i = 0; i < appList; i++) {
			// 	var item = appList[i];
			// 	if (item.name) {
			// 		var firstCharCode = item.name.charCodeAt(0);
			// 		if (48 <= firstCharCode && firstCharCode <= 57) { // isDigit
			// 			item.section = '0-9';
			// 		} else {
			// 			item.section = item.name.charAt(0).toUpperCase();
			// 		}
			// 	} else {
			// 		item.section = '?';
			// 	}
			// }

			//--- sort
			appList = appList.sort(function(a,b) {
				return a.name.toLowerCase().localeCompare(b.name.toLowerCase());
			})

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
		console.log(s, s.indexOf(substr), s.length - substr.length - 1)
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