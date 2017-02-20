import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

Item {
	id: item
	property int colSpan: 1
	property int rowSpan: 1
	width: favouritesGridView.cellWidth * colSpan
	height: favouritesGridView.cellHeight * rowSpan

	property variant tileData: config.tileData.value[model.favoriteId]
	property string tileDataLabel: tileData && tileData.label ? tileData.label : ""
	property string tileDataSize: tileData && tileData.size ? tileData.size : "medium"
	onTileDataChanged: console.log('onTileDataChanged', index, model.favoriteId, tileData)
	onTileDataLabelChanged: console.log('onTileDataLabelChanged', index, model.favoriteId, tileDataLabel)

	property string modelLabel: model.display // Used by TileEditor
	property string labelText: item.tileDataLabel || model.display || model.url || ''

	states: [
		State {
			when: item.tileDataSize == 'small'
			PropertyChanges {
				target: item
				width: favouritesGridView.cellWidth / 2
				height: favouritesGridView.cellHeight / 2
			}
			PropertyChanges { target: label; visible: false }
			PropertyChanges { target: icon; size: config.favSmallIconSize }
		},
		State {
			when: item.tileDataSize == 'medium'
			PropertyChanges {
				target: item
			}
			PropertyChanges { target: icon; size: config.favMediumIconSize }
		}
	]

	Rectangle {
		// z: 5
		anchors.centerIn: parent
		width: favouritesView.draggedItem ? favouritesView.draggedItem.width : 0
		height: favouritesView.draggedItem ? favouritesView.draggedItem.height : 0
		color: dropArea.containsDrag ? theme.highlightColor : "transparent"
		// color: "#ee0"
	}

	// Rectangle {
	// 	id: hoverOutline
	// 	visible: hoverMouseArea.containsMouse && !dropArea.containsDrag
	// 	anchors.fill: parent
	// 	border.width: config.favCellPadding
	// 	border.color: config.favHoverOutlineColor
	// 	color: "transparent"
	// }

	Item {
		anchors.fill: parent

		property bool faded: favouritesView.editing || (mouseArea.pressedButtons & Qt.LeftButton)
		opacity: faded ? 0.75 : 1
		scale: faded ? (item.width-5) / item.width : 1
		Behavior on opacity { NumberAnimation { duration: 200 } }
		Behavior on scale { NumberAnimation { duration: 200 } }


		Rectangle {
			id: itemButton
			anchors.fill: parent // Blocks drag
			// width: parent.width - anchors.margins * 2
			// height: parent.height - anchors.margins * 2
			anchors.margins: favouritesGridView.cellPadding
			color: config.defaultTileColor


			PlasmaCore.IconItem {
				id: icon
				source: model.decoration
				anchors.centerIn: parent
				property int size: 72 // Just a default, overriden in State change
				width: size
				height: size
				onSizeChanged: {
					console.log('icon', size, config.favMediumIconSize, units.devicePixelRatio)
				}
			}

			PlasmaComponents.Label {
				id: label
				text: item.tileDataLabel || model.display || model.url || ''
				anchors.leftMargin: 4
				anchors.left: parent.left
				anchors.bottom: parent.bottom
				anchors.right: parent.right
				anchors.rightMargin: 4
				wrapMode: Text.Wrap
				horizontalAlignment: config.tileLabelAlignment
				width: parent.width
				font.pointSize: 10
				renderType: Text.QtRendering // Fix pixelation when scaling. Plasma.Label uses NativeRendering.
				style: Text.Outline
				styleColor: config.defaultTileColor
			}
		}
	}
	

	DragAndDrop.DragArea {
		id: dragArea
		anchors.fill: parent
		delegate: parent

		mimeData {
			url: model.url
		}

		onDragStarted: {
			// favouritesGridView.previousState = JSON.parse(JSON.stringify(favouritesGridView.model)) // Copy
			favouritesView.draggedItem = itemButton;
			favouritesView.draggedIndex = index;
		}

		onDrop: {
			console.log('dragArea.onDrop', action)
			if (action == Qt.MoveAction) {
				
			} else { // Qt.IgnoreAction
				// favouritesGridView.model = favouritesGridView.previousState
			}
			favouritesView.draggedItem = null;
			favouritesView.draggedIndex = -1;
			
		}

		MouseArea {
			id: mouseArea
			anchors.fill: parent

			acceptedButtons: Qt.LeftButton | Qt.RightButton
			cursorShape: favouritesView.editing ? Qt.ClosedHandCursor : Qt.ArrowCursor
			onClicked: {
				console.log('click')
				console.log('mouse', mouse)
				console.log('button', mouse.button, Qt.RightButton)
				console.log('buttons', mouse.buttons, Qt.RightButton)
				mouse.accepted = true;
				if (mouse.button == Qt.RightButton) {
					contextMenu.open(mouse.x, mouse.y)
				} else if (mouse.button == Qt.LeftButton) {
					favouritesGridView.model.triggerIndex(index)
				}
			}
		}
	}

	// MouseArea {
	// 	id: hoverMouseArea
	// 	anchors.fill: parent
	// 	hoverEnabled: true
	// 	acceptedButtons: Qt.NoButton
	// 	z: 1
	// }

	AppContextMenu {
		id: contextMenu
		onPopulateMenu: {
			menu.addPinToMenuAction(model.favoriteId)
			// var actionList = favouritesGridView.model.getActionList(index)
			console.log('model.hasActionList', model.hasActionList)
			console.log('model.actionList', model.actionList)
			menu.addActionList(model.actionList, favouritesGridView.model)

			var menuItem = menu.newMenuItem()
			menuItem.text = i18n("Edit Tile")
			menuItem.icon = 'rectangle-shape'
			menuItem.onClicked.connect(function(){
				item.openTileEditor()
			})
		}
	}

	DragAndDrop.DropArea {
		id: dropArea
		anchors.fill: parent

		onDrop: {
			// console.log('dropArea.onDrop', favouritesView.draggedIndex, index)
			// console.log('possibleActions', event.possibleActions)
			// console.log('proposedAction', event.proposedAction)

			if (favouritesView.draggedIndex >= 0) { // Moving favorite around.
				// console.log('model.favoriteId', model.favoriteId)
				favouritesGridView.swap(favouritesView.draggedIndex, index)
				event.accept(Qt.MoveAction)
			} else { // Add new favorite from dolphin/desktop/taskbar.
				var favoriteId = favouritesGridView.parseDropUrl(event)
				favouritesGridView.insert(index, favoriteId)
				event.accept(Qt.CopyAction)
			}
		}

		onDragEnter: {
			// console.log('dropArea.onDragEnter', index)
		}
	}

	property var editor: null
	function openTileEditor() {
		favouritesView.editTile(model.favoriteId, item)
	}
	function closeTileEditor() {

	}
}
