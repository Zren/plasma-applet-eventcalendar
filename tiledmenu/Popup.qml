import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaCore.Dialog {
	id: popup
	visible: true
	y: widget.y - height

	// property var bottomItem: bottomMenu

	Item {
		// width: 888
		width: 360
		height: 600
		// anchors.fill: parent

		GridLayout {
			anchors.fill: parent
			columns: 1

			MenuList {
				id: topMenu
				visible: !appMenu.visible
				Layout.fillWidth: true
				// height: parent.height - parent.rowSpacing - bottomMenu.height
				// Layout.fillHeight: true

				model: ListModel {
					ListElement { label: "Power" }
					ListElement { label: "Power" }
				}

				keyNavDown: bottomMenu
			}
			Item {
				Layout.fillWidth: true
				Layout.fillHeight: true
			}
			MenuList {
				id: bottomMenu
				visible: !appMenu.visible
				Layout.fillWidth: true
				height: childrenRect.height

				model: ListModel {
					ListElement { label: "Personal Folder" }
					ListElement { label: "Settings" }
					ListElement { label: "Power" }
					ListElement { label: "All Apps" }
				}

				// KeyNavigation.up: topMenu
				// KeyNavigation.down: panelSearchBox
				keyNavUp: topMenu
				keyNavDown: panelSearchBox
			}
			MenuList {
				id: appMenu
				visible: search.isSearching
				// visible: false
				Layout.fillWidth: true
				// Layout.fillHeight: true

				model: ListModel {
					ListElement { label: "a" }
					ListElement { label: "b" }
					ListElement { label: "c" }
					ListElement { label: "d" }
				}

				// KeyNavigation.up: topMenu
				// KeyNavigation.down: panelSearchBox
				keyNavDown: panelSearchBox
			}

			TextField {
				id: panelSearchBox
				placeholderText: "Search"
				Layout.fillWidth: true
				Layout.preferredHeight: 38
				// font.pixelSize: 38
				style: TextFieldStyle {
					background: Rectangle {
						color: "#eee"
					}
				}
				onTextChanged: {
					search.query = text
				}
				Connections {
					target: search
					onQueryChanged: panelSearchBox.text = search.query
				}
				onActiveFocusChanged: {
					if (activeFocus) {
						widget.expanded = true
					}
				}

				// KeyNavigation.up: bottomMenu
				Keys.onPressed: {
					if (event.key == Qt.Key_Up) {
						if (appMenu.visible) {
							appMenu.navigateToBottom();
						} else {
							bottomMenu.navigateToBottom();
						}
						
						event.accepted = true;
					}
				}
				focus: true
			}
		}
	}
}
