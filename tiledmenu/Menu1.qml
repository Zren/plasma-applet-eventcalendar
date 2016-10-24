import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	// anchors.margins: 10
	RowLayout {
		anchors.margins: 14
		anchors.fill: parent

		Item {
			Layout.fillHeight: true
			width: 220

			ColumnLayout {
				id: menu1LeftTop
				anchors.top: parent.top
				anchors.left: parent.left
				anchors.right: parent.right
				Layout.maximumHeight: parent.height - system.height

				MenuList {
					MenuListItem {
						id: account
						iconSource: 'user'
						description: 'chris'
					}
				}

				MenuList {
					id: mostUsed
					title: 'Most used'
				}

				MenuList {
					id: recentlyAdded
					title: 'Recently added'
				}
			}
			

			MenuList {
				id: system
				anchors.left: parent.left
				anchors.right: parent.right
				anchors.bottom: parent.bottom

				MenuListItem {
					id: fileExplorer
					iconSource: 'folder-symbolic'
					description: 'File Explorer'
					showHasChildrenArrow: true
				}

				MenuListItem {
					id: settings
					iconSource: 'settings-configure'
					description: 'Settings'
				}

				MenuListItem {
					id: power
					iconSource: 'system-shutdown-symbolic'
					description: 'Power'
				}

				MenuListItem {
					id: allApps
					iconSource: 'view-list-symbolic'
					description: 'All apps'
				}
			}
		}

		RowLayout {
			// Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.alignment: Qt.AlignTop | Qt.AlignLeft
			spacing: 16

			GridSection {

			}

			GridSection {
				
			}
		}
	}
}