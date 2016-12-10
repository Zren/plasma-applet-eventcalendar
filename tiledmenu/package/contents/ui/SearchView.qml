import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

Item {
	id: searchView
	width: config.leftSectionWidth
	height: config.defaultHeight
	property alias searchResultsView: searchResultsView
	property alias appsView: appsView
	property alias searchField: searchField

	SidebarMenu {
		id: sidebarMenu
		anchors.left: parent.left
		anchors.top: parent.top
		anchors.bottom: parent.bottom

		Column {
			width: parent.width
			height: childrenRect.height

			SidebarItem {
				iconName: 'open-menu-symbolic'
				text: i18n("Menu")
				closeOnClick: false
				onClicked: sidebarMenu.open = !sidebarMenu.open
			}
			SidebarItem {
				iconName: 'view-sort-ascending-symbolic'
				text: i18n("Apps")
				onClicked: appsView.show()
				// checked: stackView.currentItem == appsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			}
			SidebarItem {
				iconName: 'system-search-symbolic'
				text: i18n("Search")
				onClicked: searchResultsView.showDefaultSearch()
				// checked: stackView.currentItem == searchResultsView
				// checkedEdge: Qt.RightEdge
				// checkedEdgeWidth: 4 * units.devicePixelRatio // Twice as thick as normal
			}
		}
		Column {
			width: parent.width
			height: childrenRect.height
			anchors.bottom: parent.bottom

			SidebarItem {
				iconName: kuser.faceIconUrl ? kuser.faceIconUrl : 'user-identity'
				text: kuser.fullName
				onClicked: KCMShell.open("user_manager")
				visible: KCMShell.authorize("user_manager.desktop").length > 0
			}
			SidebarItem {
				iconName: 'folder-open-symbolic'
				text: i18n("File Manager")
				onClicked: appsModel.launch('org.kde.dolphin')
			}
			SidebarItem {
				iconName: 'configure'
				text: i18n("Settings")
				onClicked: appsModel.launch('systemsettings')
			}

			SidebarItem {
				iconName: 'system-shutdown-symbolic'
				text: i18n("Power")
				onClicked: powerMenu.open = !powerMenu.open

				SidebarContextMenu {
					id: powerMenu
					model: appsModel.powerActionsModel
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
		anchors.fill: parent
		anchors.bottomMargin: searchField.height

		SearchResultsView {
			id: searchResultsView
			visible: false

			Connections {
				target: search
				onQueryChanged: {
					if (search.query.length > 0 && stackView.currentItem != searchResultsView) {
						stackView.push(searchResultsView, true);
					}
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
						from: stackView.height
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
		anchors.bottom: parent.bottom

		listView: stackView.currentItem ? stackView.currentItem.listView : []
	}
}
