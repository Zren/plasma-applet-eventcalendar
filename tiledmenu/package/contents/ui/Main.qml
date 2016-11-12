import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kcoreaddons 1.0 as KCoreAddons
import org.kde.draganddrop 2.0 as DragAndDrop


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

	AppletConfig {
		id: config
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
					Layout.maximumWidth: config.flatButtonSize
				}
			},
			State {
				name: "vertical"
				when: plasmoid.formFactor == PlasmaCore.Types.Vertical
				PropertyChanges {
					target: panelItem
					Layout.minimumHeight: 24
					Layout.preferredHeight: panelItem.width
					Layout.maximumHeight: config.flatButtonSize
				}
			}
		]

		LauncherIcon {
			iconSource: plasmoid.configuration.icon || "start-here-kde"
			iconSize: Math.min(config.panelIconSize, panelItem.width, panelItem.height)
			anchors.fill: parent
			onClicked: {
				plasmoid.expanded = !plasmoid.expanded
			}

			DragAndDrop.DropArea {
				id: dropArea
				anchors.fill: parent

				onDragEnter: {
					activateOnDrag.restart()
				}
			}

			onContainsMouseChanged: {
				if (!containsMouse) {
					activateOnDrag.stop()
				}
			}

			Timer {
				id: activateOnDrag
				interval: 250 // Same as taskmanager's activationTimer in MouseHandler.qml
				onTriggered: plasmoid.expanded = true
			}
		}
	}

	property bool expanded: plasmoid.expanded
	onExpandedChanged: {
		if (expanded) {
			search.query = ""
			search.applyDefaultFilters()
			popup.searchView.searchField.forceActiveFocus()
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
	Layout.preferredWidth: config.popupWidth
	Layout.preferredHeight: config.popupHeight

	onWidthChanged: {
		// console.log('popup.size', width, height, 'width')
		// plasmoid.configuration.width = width
		resizeToFit.restart()
	}
	onHeightChanged: {
		// console.log('popup.size', width, height, 'height')
		plasmoid.configuration.height = height
	}
	Timer {
		id: resizeToFit
		interval: 400
		onTriggered: {
			var favWidth = Math.max(0, widget.width - config.leftSectionWidth) // 398 // 888-60-430
			var cols = Math.floor(favWidth / config.favColWidth)
			var newWidth = config.leftSectionWidth + cols * config.favColWidth
			if (newWidth != widget.width) {
				// widget.Layout.preferredWidth = newWidth
				plasmoid.configuration.width = newWidth
				// console.log('resizeToFit', cols, favWidth, newWidth - config.favColWidth)
			}
		}
	}
	// Layout.onPreferredWidthChanged: console.log('popup.size', width, height)
	// Layout.onPreferredHeightChanged: console.log('popup.size', width, height)


	onFocusChanged: {
		if (focus) {
			popup.searchView.searchField.forceActiveFocus()
		}
	}

	function action_menuedit() {
		processRunner.runMenuEditor();
	}

	Component.onCompleted: {
		plasmoid.setAction("menuedit", i18n("Edit Applications..."));
		// plasmoid.action('configure').trigger()
	}
}
