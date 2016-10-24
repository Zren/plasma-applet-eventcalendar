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
				id: appMenu
				width: parent.width
				Layout.fillHeight: true
				clip: true
				cacheBuffer: 1000 // Don't unload when scrolling (prevent stutter)

				model: PlasmaCore.SortFilterModel {
					sourceModel: runnerModel
					sortRole: 'name'
					// sortRole
				}
				delegate: Column {
					visible: runner.count > 0
					width: parent.width
					height: visible ? childrenRect.height : 0
					property var runner: runnerModel.modelForRow(appMenu.model.mapRowToSource(index))
					property int index1: index
					Component.onCompleted: {
						console.log('runnerModel[' + index + ']', runner, runner.name, model, modelData)
					}

					spacing: 10

					PlasmaComponents.Label {
						text: runner.name || '?'
						font.pixelSize: 22
					}
					Repeater { // ItemListView
						width: parent.width
						height: childrenRect.height
						model: runner
						delegate: MenuListItem {}
					}
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
