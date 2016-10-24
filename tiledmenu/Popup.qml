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

		// PlasmaComponents.Label {
		// 	visible: false
		// 	text: ""
		// 	color: "#888"
		// 	maximumLineCount: 1
		// 	elide: Text.ElideRight
		// }

		GridLayout {
			anchors.fill: parent
			columns: 1

			// Item {
			// 	Layout.fillWidth: true
			// 	Layout.fillHeight: true
			// }

			ListView { // RunnerResultsList
				id: searchMenu
				width: parent.width
				Layout.fillHeight: true
				clip: true
				cacheBuffer: 1000 // Don't unload when scrolling (prevent stutter)

				model: resultModel
				delegate: MenuListItem {}
				
				section.property: 'runnerName'
				section.criteria: ViewSection.FullString
				section.delegate: PlasmaComponents.Label {
					text: section
				}

				Connections {
					target: resultModel
					onRefreshed: {
						console.log('resultModel.onRefreshed')
						searchMenu.currentIndex = 0
					}
				}

				highlight: PlasmaComponents.Highlight {
					anchors.fill: searchMenu.currentItem;

					visible: searchMenu.currentItem && !searchMenu.currentItem.isSeparator
				}

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
			}
		}
	}
}
