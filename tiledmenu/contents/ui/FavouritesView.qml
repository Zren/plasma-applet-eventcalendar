import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

ScrollView {
	id: favouritesView
	// width: (favouritesGridView.cellWidth * favouritesGridView.columns) // 380
	// height: parent.height

	width: 888-60-430
	height: 620

	property bool editing: draggedItem
	property QtObject draggedItem: null
	property int draggedIndex: -1

	style: ScrollViewStyle {
		transientScrollBars: true
	}

	Item {
		// Wrap the gridview so items with a rowSpan >= 2 are drawn when the first row is cut off.
		width: favouritesGridView.width
		height: favouritesGridView.height

		GridView {
			id: favouritesGridView
			// anchors.fill: parent
			cellWidth: 60 + cellPadding * 2
			cellHeight: 60 + cellPadding * 2
			property int cellPadding: 3
			property int columns: Math.floor(favouritesView.width / cellWidth)
			property int rows: Math.ceil(model.length / columns)
			width: cellWidth * columns
			height: cellHeight * rows

			delegate: Item {
				id: item
				property int colSpan: 1
				property int rowSpan: 1
				width: favouritesGridView.cellWidth * colSpan
				height: favouritesGridView.cellHeight * rowSpan
				z: modelData.placeholder ? -1 : 0 // Don't select placeholders (but cancel when dragging).

				// state: 'medium'
				property string size: modelData.size || 'small'
				states: [
					State {
						when: item.size == 'small'
						PropertyChanges {
							target: item
							colSpan: 1
							rowSpan: 1
						}
						PropertyChanges { target: label; visible: false }
						PropertyChanges { target: icon; size: 32 }
					},
					State {
						when: item.size == 'medium'
						PropertyChanges {
							target: item
							colSpan: 2
							rowSpan: 2
						}
						PropertyChanges { target: icon; size: 72 }
					},
					State {
						when: item.size == 'wide'
						PropertyChanges {
							target: item
							colSpan: 4
							rowSpan: 2
						}
						PropertyChanges { target: icon; size: 72 }
					},
					State {
						when: item.size == 'large'
						PropertyChanges {
							target: item
							colSpan: 4
							rowSpan: 4
						}
						PropertyChanges { target: icon; size: 92 }
					}
				]

				Rectangle {
					// z: 5
					width: favouritesView.draggedItem ? favouritesView.draggedItem.width : 0
					height: favouritesView.draggedItem ? favouritesView.draggedItem.height : 0
					color: dropArea.containsDrag ? theme.highlightColor : "transparent"
					// color: "#ee0"
				}
				Item {
					anchors.fill: parent

					opacity: favouritesView.editing ? 0.75 : 1
					scale: favouritesView.editing ? (item.width-5) / item.width : 1
					Behavior on opacity { NumberAnimation { duration: 200 } }
					Behavior on scale { NumberAnimation { duration: 200 } }


					Rectangle {
						id: itemButton
						visible: !modelData.placeholder
						anchors.fill: parent // Blocks drag
						// width: parent.width - anchors.margins * 2
						// height: parent.height - anchors.margins * 2
						anchors.margins: favouritesGridView.cellPadding
						color: theme.buttonBackgroundColor


						PlasmaCore.IconItem {
							id: icon
							source: modelData.decoration
							anchors.centerIn: parent
							property int size: 72
							width: size
							height: size
						}

						PlasmaComponents.Label {
							id: label
							text: modelData.display || ''
							anchors.leftMargin: 4
							anchors.left: parent.left
							anchors.bottom: parent.bottom
							wrapMode: Text.Wrap
							width: parent.width
							font.pointSize: 11
							renderType: Text.QtRendering // Fix pixelation when scaling. Plasma.Label uses NativeRendering.
						}
					}
				}
				

				DragAndDrop.DragArea {
					id: dragArea
					anchors.fill: parent
					enabled: !modelData.placeholder
					delegate: parent

					// mimeData {
					// 	source: item
					// }

					onDragStarted: {
						favouritesGridView.previousState = JSON.parse(JSON.stringify(favouritesGridView.model)) // Copy
						favouritesView.draggedItem = itemButton;
						favouritesView.draggedIndex = index;
					}

					onDrop: {
						console.log('dragArea.onDrop', action)
						if (action == Qt.MoveAction) {
							
						} else { // Qt.IgnoreAction
							favouritesGridView.model = favouritesGridView.previousState
						}
						favouritesView.draggedItem = null;
						favouritesView.draggedIndex = -1;
						
					}
			
					MouseArea {
						id: mouseArea
						anchors.fill: parent

						cursorShape: favouritesView.editing ? Qt.ClosedHandCursor : Qt.ArrowCursor
						onClicked: {
							console.log('click')
						}
					}
				}

				DragAndDrop.DropArea {
					id: dropArea
					// anchors.fill: parent
					width: favouritesGridView.cellWidth
					height: favouritesGridView.cellHeight
					z: modelData.placeholder ? 1000 : 0

					onDrop: {
						console.log('dropArea.onDrop', index)
						favouritesGridView.previewDrop(favouritesView.draggedIndex, index)
					}

					onDragEnter: {
						console.log('dropArea.onDragEnter', index)
					}
				}
			}
			
			property var previousState: null

			// systemsettings.desktop,sublime-text.desktop,clementine.desktop,hexchat.desktop,virtualbox.desktop
			model: [
				{ display: 'System Settings', decoration: 'systemsettings', size: 'medium' },
				{ placeholder: true },
				{ display: 'Sublime Text', decoration: 'sublime-text', size: 'wide' },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ display: 'System Settings', decoration: 'systemsettings', size: 'small' },
				{ display: 'Comix', decoration: 'comix', size: 'small' },
				{ display: 'System Settings', decoration: 'systemsettings', size: 'large' },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ display: 'VirtualBox', decoration: 'virtualbox', size: 'medium' },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ display: 'VirtualBox', decoration: 'virtualbox', size: 'large' },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },
				{ placeholder: true },

			]

			function previewDrop(indexA, indexB) {
				var newState = JSON.parse(JSON.stringify(favouritesGridView.previousState))
				
				moveItem(newState, indexA, indexB)
				// console.log(JSON.stringify(newState))
				favouritesGridView.model = newState
			}

			function moveItem(newState, indexA, indexB) {
				console.log('moveItem', indexA, indexB)
				console.log('\t' + JSON.stringify(newState[indexA]))
				console.log('\t' + JSON.stringify(newState[indexB]))

				var colSpanBySize = {
					'small': 1,
					'medium': 2,
					'wide': 4,
					'large': 4,
				}
				var rowSpanBySize = {
					'small': 1,
					'medium': 2,
					'wide': 2,
					'large': 4,
				}

				var obj = newState[indexA];
				var colSpanA = colSpanBySize[obj.size] || 1;
				var rowSpanA = rowSpanBySize[obj.size] || 1;
				var colA = indexA % favouritesGridView.columns;
				var rowA = Math.floor(indexA / favouritesGridView.columns);

				var colB = indexB % favouritesGridView.columns;
				var rowB = Math.floor(indexB / favouritesGridView.columns);

				// console.log('rightCheck', colB, colSpanA)
				if (colB + colSpanA >= favouritesGridView.columns) {
					indexB = rowB * favouritesGridView.columns + favouritesGridView.columns - colSpanA;
					// console.log('indexB', indexB)
				}

				newState.splice(indexA, 1, { placeholder: true}); // Replace old item with placeholder
				
				// Shift objects in way
				for (var dy = 0; dy < rowSpanA; dy++) {
					for (var dx = 0; dx < colSpanA; dx++) {
						var indexC = indexB + dy * favouritesGridView.columns + dx;

						// Add more rows if needed. A throttle of 100 new rows.
						// We should never need to add more than 4, but it's better for it error and gobble the launcher than an "inf loop".
						for (var i = 0; i < 100; i++) {
							if (typeof newState[indexC] === 'undefined') {
								addRow(newState);
							}
						}
						
						if (newState[indexC].placeholder) {
							
						} else {
							moveItem(newState, indexC, indexC + favouritesGridView.columns) // Move down a row
						}
					}
				}

				// Add item
				newState.splice(indexB, 1, obj); // Remove placeholder and add obj
			}

			function addRow(newState) {
				console.log('addRow');
				for (var x = 0; x < favouritesGridView.columns; x++) {
					newState.push({ placeholder: true });
				}
			}
		}
	}
}
