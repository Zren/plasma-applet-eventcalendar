import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons

Item {
	id: widget

	property alias expanded: plasmoid.expanded

	
	SearchModel {
		id: search
		Component.onCompleted: {
			search.applyDefaultFilters()
		}
	}

	property alias rootModel: appsModel.rootModel
	AppsModel {
		id: appsModel
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
}
