import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

// import "tiledmenu3" as TM3

Item {
	id: searchView
	width: config.leftSectionWidth
	height: config.popupHeight
	property alias searchResultsView: searchResultsView
	property alias appsView: appsView
	property alias tileEditorView: tileEditorViewLoader.item
	property alias tileEditorViewLoader: tileEditorViewLoader
	property alias searchField: searchField

	property bool searchOnTop: false

	states: [
		State {
			name: "searchOnTop"
			when: searchOnTop
			PropertyChanges {
				target: stackViewContainer
				anchors.topMargin: searchField.height
			}
			PropertyChanges {
				target: searchField
				anchors.top: searchField.parent.top
			}
		},
		State {
			name: "searchOnBottom"
			when: !searchOnTop
			PropertyChanges {
				target: stackViewContainer
				anchors.bottomMargin: searchField.height
			}
			PropertyChanges {
				target: searchField
				anchors.bottom: searchField.parent.bottom
			}
		}
	]

	SidebarMenu {
		id: sidebarMenu
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom

		Behavior on width { NumberAnimation { duration: 100 } }

		Column {
			id: sidebarMenuTop
			width: parent.width
			height: childrenRect.height

			SidebarItem {
				iconName: 'open-menu-symbolic'
				text: i18n("Menu")
				closeOnClick: false
				onClicked: sidebarMenu.open = !sidebarMenu.open
				zoomOnPush: expanded
			}
			SidebarItem {
				iconName: 'view-sort-ascending-symbolic'
				text: i18n("Apps")
				onClicked: {
					appsModel.order = "alphabetical"
					appsView.show()
				}
				// checked: stackView.currentItem == appsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			}
			SidebarItem {
				iconName: 'view-list-tree'
				text: i18n("Categories")
				onClicked: {
					appsModel.order = "categories"
					appsView.show()
				}
				// checked: stackView.currentItem == appsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			}
			// SidebarItem {
			// 	iconName: 'system-search-symbolic'
			// 	text: i18n("Search")
			// 	onClicked: searchResultsView.showDefaultSearch()
			// 	// checked: stackView.currentItem == searchResultsView
			// 	// checkedEdge: Qt.RightEdge
			// 	// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			// }
		}
		Column {
			width: parent.width
			height: childrenRect.height
			anchors.bottom: parent.bottom

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				onClicked: userMenu.open = !userMenu.open

				SidebarContextMenu {
					id: userMenu

					SidebarItem {
						iconName: 'system-users'
						text: i18n("User Manager")
						onClicked: KCMShell.open('user_manager')
						visible: KCMShell.authorize('user_manager.desktop').length > 0
					}

					SidebarItemRepeater {
						model: appsModel.sessionActionsModel
					}
				}
			}

			// Repeater {
			// 	model: appsModel.sidebarModel
			// 	onCountChanged: console.log(count, 'appsModel.sidebarModel', appsModel.sidebarModel)

			// 	delegate: SidebarItem {

			// 	}

			// }
			SidebarFavouritesView {
				model: appsModel.sidebarModel
				maxHeight: sidebarMenu.height - sidebarMenuTop.height - 2 * config.flatButtonSize
			}

			// SidebarItem {
			// 	iconName: 'folder-open-symbolic'
			// 	text: i18n("File Manager")
			// 	onClicked: appsModel.launch('org.kde.dolphin')
			// }
			// SidebarItem {
			// 	iconName: 'configure'
			// 	text: i18n("Settings")
			// 	onClicked: appsModel.launch('systemsettings')
			// }

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				text: i18n("Power")
				onClicked: powerMenu.open = !powerMenu.open

				SidebarContextMenu {
					id: powerMenu
					
					SidebarItemRepeater {
						model: appsModel.powerActionsModel
					}
				}
			}
		}

		onFocusChanged: {
			console.log('onFocusChanged', focus)
			if (!focus) {
				open = false
			}
		}
	}


	Item {
		id: stackViewContainer
		anchors.fill: parent

		SearchResultsView {
			id: searchResultsView
			visible: false

			Connections {
				target: search
				onQueryChanged: {
					if (search.query.length > 0 && stackView.currentItem != searchResultsView) {
						stackView.push(searchResultsView, true)
					}
					searchResultsView.filterViewOpen = false
				}
			}

			onVisibleChanged: {
				if (!visible) { // !stackView.currentItem
					search.query = ""
				}
			}

			function showDefaultSearch() {
				if (stackView.currentItem != searchResultsView) {
					stackView.push(searchResultsView, true)
				}
				search.applyDefaultFilters()
			}
		}
		
		AppsView {
			id: appsView
			visible: false

			function show() {
				if (stackView.currentItem != appsView) {
					stackView.push(appsView, true)
				}
				appsView.scrollToTop()
			}
		}

		// TM3.Main {
		// 	id: appsView
		// 	// width: parent.width
		// 	// height: parent.height

		// 	function show() {
		// 		if (stackView.currentItem != appsView) {
		// 			stackView.push(appsView, true)
		// 		}
		// 		appsView.scrollToTop()
		// 	}
		// }

		// Item {
		// 	id: appsView
		// }

		Loader {
			id: tileEditorViewLoader
			source: "TileEditorView.qml"
			visible: false
			active: false
			// asynchronous: true
			function open(tile) {
				active = true
				item.open(tile)
			}
		}

		StackView {
			id: stackView
			width: config.appListWidth
			clip: true
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.bottom: parent.bottom
			initialItem: appsView

			delegate: StackViewDelegate {
				pushTransition: StackViewTransition {
					PropertyAnimation {
						target: enterItem
						property: "y"
						from: stackView.height * (searchView.searchOnTop ? -1 : 1)
						to: 0
					}
					PropertyAnimation {
						target: exitItem
						property: "opacity"
						from: 1
						to: 0
					}
				}
				
				function transitionFinished(properties) {
					properties.exitItem.opacity = 1
				}
			}
		}
	}


	SearchField {
		id: searchField
		// width: 430
		height: config.searchFieldHeight
		anchors.leftMargin: config.sidebarWidth
		anchors.left: parent.left
		anchors.right: parent.right

		listView: stackView.currentItem && stackView.currentItem.listView ? stackView.currentItem.listView : []
	}
}
