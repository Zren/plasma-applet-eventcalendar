import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons


Item {
	id: widget

	SearchModel {
		id: search
		Component.onCompleted: {
			search.applyDefaultFilters()
		}
	}

	property alias rootModel: appsModel.rootModel
	AppsModel {
		id: appsModel

		Component.onCompleted: {
			
		}
	}

	Item {
		KCoreAddons.KUser {
			id: kuser
		}
		
		Kicker.SystemSettings {
			id: systemSettings
		}

		Kicker.DragHelper {
			id: dragHelper

			dragIconSize: units.iconSizes.medium
		}

		Kicker.ProcessRunner {
			id: processRunner
			// .runMenuEditor() to run kmenuedit
		}

		Kicker.WindowSystem {
			id: windowSystem
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
		//  console.log(label, Object.keys(obj))
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



	Plasmoid.compactRepresentation: Item {
		id: panelItem
		
		states: [
			State {
				name: "horizontal"
				when: plasmoid.formFactor == PlasmaCore.Types.Horizontal
				PropertyChanges {
					target: panelItem
					Layout.minimumWidth: 24
					Layout.preferredWidth: panelItem.height
					Layout.maximumWidth: 60
				}
			},
			State {
				name: "vertical"
				when: plasmoid.formFactor == PlasmaCore.Types.Vertical
				PropertyChanges {
					target: panelItem
					Layout.minimumHeight: 24
					Layout.preferredHeight: panelItem.width
					Layout.maximumHeight: 60
				}
			}
		]

		LauncherIcon {
			iconSource: "start-here-kde"
			iconSize: 24
			anchors.fill: parent
			onClicked: {
				plasmoid.expanded = !plasmoid.expanded
			}
		}
	}

	property bool expanded: plasmoid.expanded
	onExpandedChanged: {
		if (expanded) {
			search.query = ""
			search.applyDefaultFilters()
			popup.searchView.searchField.forceActiveFocus()
			// appsModel.allAppsModel.refresh()
			popup.searchView.appsView.show()
		}
	}

	// property alias searchResultsView: popup.searchView.searchResultsView
	// width: popup.width
	// height: popup.height
	Popup {
		id: popup
		anchors.fill: parent
	}
	width: 888
	height: 620

	onWidthChanged: console.log('popup.size', width, height)
	onHeightChanged: console.log('popup.size', width, height)
	// Layout.onPreferredWidthChanged: console.log('popup.size', width, height)
	// Layout.onPreferredHeightChanged: console.log('popup.size', width, height)


	onFocusChanged: {
		if (focus) {
			popup.searchView.searchField.forceActiveFocus()
		}
	}
}
