import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ScrollView {
	id: appsView
	property alias listView: appsListView

	KickerListView {
		id: appsListView
		
		section.property: 'sectionKey'
		// section.criteria: ViewSection.FirstCharacter

		// model: appsModel.allAppsModel // Should be populated by the time this is created
		model: KickerListModel {
			id: appsViewModel

			onItemTriggered: {
				console.log('appsViewModel.onItemTriggered')
				plasmoid.expanded = false;
			}

			function refresh() {
				refreshing()
				
				// console.log('resultModel.refresh')
				//--- populate list
				var appList = [];

				//--- Recent Apps
				appList = appList.concat(appsModel.recentAppsModel.list);

				//--- Apps A-Z
				appList = appList.concat(appsModel.allAppsModel.list);

				//--- apply model
				appsViewModel.list = appList;
				// appsViewModel.log();

				refreshed()
			}
		}
		Connections {
			target: appsModel.recentAppsModel
			onRefreshed: appsViewModel.refresh()
		}
		Connections {
			target: appsModel.allAppsModel
			onRefreshed: appsViewModel.refresh()
		}

		showItemUrl: false
		largeFirstItem: false
	}

	function scrollToTop() {
		appsListView.positionViewAtBeginning()
	}
}
