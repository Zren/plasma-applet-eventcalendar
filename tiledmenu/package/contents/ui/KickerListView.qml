import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

ListView {
	id: listView
	width: parent.width
	Layout.fillHeight: true
	clip: true
	cacheBuffer: 1000 // Don't unload when scrolling (prevent stutter)

	// snapMode: ListView.SnapToItem
	keyNavigationWraps: true
	highlightMoveDuration: 0
	highlightResizeDuration: 0

	property bool showItemUrl: true
	property bool largeFirstItem: true

	section.delegate: PlasmaComponents.Label {
		text: section
		font.bold: true
		font.pointSize: 14
	}

	delegate: AppToolButton {
		id: itemDelegate

		width: parent.width
		height: row.height

		property var parentModel: modelList[index] ? modelList[index].parentModel : undefined
		property string description: model.url ? model.description : '' // 
		property string secondRowText: listView.showItemUrl && model.url ? model.url : model.description
		property bool secondRowVisible: secondRowText

		DragAndDrop.DragArea {
			id: dragArea
			anchors.fill: parent
			
			delegate: itemDelegate
			// enabled: model.url
			supportedActions: Qt.CopyAction

			mimeData {
				text: model.favoriteId 
				url: model.favoriteId // ? model.favoriteId : model.url
			}
		}

		RowLayout { // ItemListDelegate
			id: row
			width: parent.width
			// height: 36 // 2 lines
			height: listView.largeFirstItem && index == 0 ? 64 : 36

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
					// source: model.decoration
					source: appsModel.allAppsModel.list[index].icon
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
						color: "#888"
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
					color: "#888"
					maximumLineCount: 1
					elide: Text.ElideMiddle
					height: implicitHeight
				}
			}

		}

		acceptedButtons: Qt.LeftButton | Qt.RightButton
		onClicked: {
			mouse.accepted = true
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
				var menuItem = menu.newMenuItem();
				if (appsModel.favoritesModel.isFavorite(model.favoriteId)) {
					menuItem.text = i18n("Unpin from Menu")
					menuItem.icon = "list-remove"
					menuItem.clicked.connect(function() {
						appsModel.favoritesModel.removeFavorite(model.favoriteId)
					})
				} else {
					menuItem.text = i18n("Pin to Menu")
					menuItem.icon = "bookmark-new"
					menuItem.clicked.connect(function() {
						console.log('model.favoriteId', model.favoriteId)
						appsModel.favoritesModel.addFavorite(model.favoriteId)
					})
				}
				menu.addMenuItem(menuItem)
			}
		}

	} // delegate: AppToolButton

	property var modelList: model ? model.list : []
	
	// currentIndex: 0
	// Connections {
	// 	target: appsModel.allAppsModel
	// 	onRefreshing: {
	// 		console.log('appsList.onRefreshing')
	// 		appsList.model = []
	// 		// console.log('search.results.onRefreshed')
	// 		appsList.currentIndex = 0
	// 	}
	// 	onRefreshed: {
	// 		console.log('appsList.onRefreshed')
	// 		// appsList.model = appsModel.allAppsList
	// 		appsList.model = appsModel.allAppsList
	// 		appsList.modelList = appsModel.allAppsList.list
	// 		appsList.currentIndex = 0
	// 	}
	// }

	highlight: PlasmaComponents.Highlight {
		visible: listView.currentItem && !listView.currentItem.isSeparator
	}

	// function triggerIndex(index) {
	// 	model.triggerIndex(index)
	// }
}
