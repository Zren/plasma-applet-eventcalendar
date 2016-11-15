import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

AppToolButton {
	id: itemDelegate

	width: parent.width
	height: row.height

	property var parentModel: typeof modelList !== "undefined" && modelList[index] ? modelList[index].parentModel : undefined
	property string description: model.url ? model.description : '' // 
	property string secondRowText: listView.showItemUrl && model.url ? model.url : model.description
	property bool secondRowVisible: secondRowText
	property string launcherUrl: model.favoriteId || model.url
	property alias iconSource: itemIcon.source

	// DragAndDrop.DragArea {
	// 	id: dragArea
	// 	anchors.fill: parent
		
	// 	delegate: itemDelegate
	// 	supportedActions: Qt.CopyAction
	// 	enabled: launcherUrl

	// 	mimeData {
	// 		url: launcherUrl
	// 	}
	// }

	RowLayout { // ItemListDelegate
		id: row
		width: parent.width
		// height: 36 // 2 lines
		height: (listView.largeFirstItem && index == 0 ? 64 : 36) * units.devicePixelRatio	

		Item {
			height: parent.height
			width: parent.height
			// width: itemIcon.width
			Layout.fillHeight: true

			PlasmaCore.IconItem {
				id: itemIcon
				anchors.centerIn: parent
				height: parent.height
				width: height
				// height: 48
				

				// height: parent.height
				// width: height

				// visible: iconsEnabled

				animated: false
				// usesPlasmaTheme: false
				source: listView.model.list[index].icon
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			// Layout.fillHeight: true
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0

			RowLayout {
				Layout.fillWidth: true
				// height: itemLabel.height

				PlasmaComponents.Label {
					id: itemLabel
					text: model.name
					maximumLineCount: 1
					// elide: Text.ElideMiddle
					height: implicitHeight
				}

				PlasmaComponents.Label {
					Layout.fillWidth: true
					text: !itemDelegate.secondRowVisible ? itemDelegate.description : ''
					color: config.menuItemTextColor2
					maximumLineCount: 1
					elide: Text.ElideRight
					height: implicitHeight // ElideRight causes some top padding for some reason
				}
			}

			PlasmaComponents.Label {
				visible: itemDelegate.secondRowVisible
				Layout.fillWidth: true
				// Layout.fillHeight: true
				text: itemDelegate.secondRowText
				color: config.menuItemTextColor2
				maximumLineCount: 1
				elide: Text.ElideMiddle
				height: implicitHeight
			}
		}

	}

	acceptedButtons: Qt.LeftButton | Qt.RightButton
	onClicked: {
		mouse.accepted = true
		console.log('onClicked', mouse.button, Qt.LeftButton, Qt.RightButton)
		if (mouse.button == Qt.LeftButton) {
			trigger()
		} else if (mouse.button == Qt.RightButton) {
			contextMenu.open(mouse.x, mouse.y)
		}
	}

	function trigger() {
		listView.model.triggerIndex(index)
	}

	AppContextMenu {
		id: contextMenu
		onPopulateMenu: {
			// Pin to Menu
			if (launcherUrl) {
			var menuItem = menu.newMenuItem();
				if (appsModel.favoritesModel.isFavorite(launcherUrl)) {
					menuItem.text = i18n("Unpin from Menu")
					menuItem.icon = "list-remove"
					menuItem.clicked.connect(function() {
						appsModel.favoritesModel.removeFavorite(launcherUrl)
					})
				} else {
					menuItem.text = i18n("Pin to Menu")
					menuItem.icon = "bookmark-new"
					menuItem.clicked.connect(function() {
						// console.log('launcherUrl', launcherUrl)
						appsModel.favoritesModel.addFavorite(launcherUrl)
					})
				}
				menu.addMenuItem(menuItem)
			}
		}
	}

} // delegate: AppToolButton