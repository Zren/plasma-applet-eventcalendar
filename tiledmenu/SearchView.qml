import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	// width: 888
	width: 60 + 430
	height: 620
	// anchors.fill: parent

	// width: 60
	// width: 430
	// height: 620

	Item {
		anchors.fill: parent
		anchors.bottomMargin: 50

		SidebarMenu {
			id: sidebarMenu
			width: open ? 200 : 60
			anchors.left: parent.left
			anchors.top: parent.top
			anchors.bottom: parent.bottom
			z: 1
			clip: true
			property bool open: false

			Rectangle {
				anchors.fill: parent
				color: "#000"
				// color: sidebarMenu.open ? "#000" : "transparent"
				opacity: sidebarMenu.open ? 1 : 0.5
			}

			Column {
				width: parent.width
				height: childrenRect.height

				SidebarItem {
					iconName: 'open-menu-symbolic'
					text: "Menu"
					closeOnClick: false
					onClicked: sidebarMenu.open = !sidebarMenu.open
				}
				SidebarItem {
					iconName: 'go-home'
					text: sidebarMenu.open ? "Home" : ""
					onClicked: search.filters = []
				}
			}
			Column {
				width: parent.width
				height: childrenRect.height
				anchors.bottom: parent.bottom

				SidebarItem {
					iconName: 'configure'
					text: sidebarMenu.open ? "Settings" : ""
					enabled: false
					// onClicked: sidebarMenu.open = !sidebarMenu.open
				}
			}
		}

		SearchResultsView {
			id: searchResultsView
			width: 430
			anchors.top: parent.top
			anchors.right: parent.right
			anchors.bottom: parent.bottom
		}
	}

	RowLayout {
		height: 50
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		spacing: 0

		Rectangle {
			color: "#000"
			width: 60
			height: parent.height
			opacity: sidebarMenu.open ? 1 : 0.5
		}
		SearchField {
			id: panelSearchBox
			width: 430
		}
	}
	
}