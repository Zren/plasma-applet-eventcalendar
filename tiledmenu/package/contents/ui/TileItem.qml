import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

Item {
	id: tileItem
	x: modelData.x * cellBoxSize
	y: modelData.y * cellBoxSize
	width: modelData.w * cellBoxSize
	height: modelData.h * cellBoxSize

	AppObject {
		id: appObj
		tile: modelData
	}
	readonly property alias app: appObj.app

	readonly property bool faded: tileGrid.editing || tileMouseArea.pressed
	readonly property int fadedWidth: width - cellPushedMargin
	opacity: faded ? 0.75 : 1
	scale: faded ? fadedWidth / width : 1
	Behavior on opacity { NumberAnimation { duration: 200 } }
	Behavior on scale { NumberAnimation { duration: 200 } }

	//--- View Start
	TileItemView {
		id: tileItemView
		anchors.fill: parent
		anchors.margins: cellMargin
		width: modelData.w * cellBoxSize
		height: modelData.h * cellBoxSize
		hovered: tileMouseArea.containsMouse
	}

	Rectangle {
		anchors.fill: parent
		visible: tileMouseArea.containsMouse
		color: "transparent"
		border.color: "#88ffffff"
		border.width: hoverOutlineSize
	}
	//--- View End

	DragAndDrop.DragArea {
		anchors.fill: parent
		delegate: tileItemView
		onDragStarted: {
			console.log('onDragStarted', JSON.stringify(modelData), index, tileModel.length)
			// tileGrid.draggedItem = tileModel.splice(index, 1)[0]
			tileGrid.startDrag(index)
		}
		onDrop: {
			console.log('DragArea.onDrop', draggedItem)
			tileGrid.resetDrag()
		}

		MouseArea {
			id: tileMouseArea
			anchors.fill: parent
			hoverEnabled: true

			acceptedButtons: Qt.LeftButton | Qt.RightButton
			cursorShape: editing ? Qt.ClosedHandCursor : Qt.ArrowCursor
			
			// This MouseArea will spam "QQuickItem::ungrabMouse(): Item is not the mouse grabber."
			// but there's no other way of having a clickable drag area.
			onClicked: {
				mouse.accepted = true
				if (mouse.button == Qt.LeftButton) {
					if (tileEditorView.tile) {
						openTileEditor()
					} else {
						appsModel.tileGridModel.runApp(modelData.url)
					}
				} else if (mouse.button == Qt.RightButton) {
					contextMenu.open(mouse.x, mouse.y)
				}
			}
		}
	}

	AppContextMenu {
		id: contextMenu
		tileIndex: index
		onPopulateMenu: {
			menu.addPinToMenuAction(modelData.url)
			
			appObj.addActionList(menu)

			var menuItem = menu.newMenuItem()
			menuItem.text = i18n("Edit Tile")
			menuItem.icon = 'rectangle-shape'
			menuItem.onClicked.connect(function(){
				tileItem.openTileEditor()
			})
		}
	}

	function openTileEditor() {
		tileGrid.editTile(tileGrid.tileModel[index])
	}
	function closeTileEditor() {

	}
}
