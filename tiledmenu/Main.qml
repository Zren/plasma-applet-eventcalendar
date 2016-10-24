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

	SearchModel {
		id: search
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
		// search.query = ""
	}
}
