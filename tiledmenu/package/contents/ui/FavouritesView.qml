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

	width: config.favViewDefaultWidth
	height: config.defaultHeight

	property bool editing: draggedItem
	property QtObject draggedItem: null
	property int draggedIndex: -1

	__wheelAreaScrollSpeed: 142
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
			cellWidth: config.favColWidth
			cellHeight: config.favColWidth
			property int cellPadding: config.favCellPadding
			property int columns: Math.floor(favouritesView.width / cellWidth)
			property int rows: Math.ceil(model.count / columns)
			width: cellWidth * columns
			height: cellHeight * rows
			interactive: false // Disable drag to scroll (ScrollView handles it)

			delegate: Item {
				id: item
				property int colSpan: 1
				property int rowSpan: 1
				width: favouritesGridView.cellWidth * colSpan
				height: favouritesGridView.cellHeight * rowSpan

				// Medium (until we can make this configurable)
				property string size: 'medium'
				states: [
					State {
						when: item.size == 'medium'
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
							text: model.display || model.url || ''
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

				AppContextMenu {
					id: contextMenu
					onPopulateMenu: {
						// Pin to Menu
						var menuItem = menu.newMenuItem();
						if (appsModel.favoritesModel.isFavorite(model.favoriteId)) {
							menuItem.text = i18n("Unpin from Menu")
							menuItem.icon = "list-remove"
							menuItem.clicked.connect(function() {
								appsModel.favoritesModel.removeFavorite(model.favoriteId)
							})
						} else {
							menuItem.text = i18n("Pin to Menu")
							menuItem.icon = "bookmark-new"
							menuItem.clicked.connect(function() {
								appsModel.favoritesModel.addFavorite(model.favoriteId)
							})
						}
						menu.addMenuItem(menuItem)

						// Pin to Taskbar
						// console.log('nullcheck', model.favoriteId, model.favoriteId != null, "hasActionList" in model)
						// console.log('model.hasActionList', model.hasActionList) // true
						// console.log('model.actionList.length', model.actionList.length) // crashes plasmoidviewer...
						// var action = model.actionList[0];
						// console.log('action', action)
						// console.log('action.name', action.name)
						// var menuItem = menu.newMenuItem();
						// menuItem.text = action.name() //i18n("Pin to Menu")
						// menuItem.icon = "bookmark-new"
						// menu.addMenuItem(menuItem)
					}
				}

				DragAndDrop.DropArea {
					id: dropArea
					// anchors.fill: parent
					width: favouritesGridView.cellWidth
					height: favouritesGridView.cellHeight

					// function nameOf(i) {
					// 	return favouritesGridView.model.data(favouritesGridView.model.index(i, 0), Qt.DisplayRole)
					// }
					
					function moveTo(a, b) {
						// console.log(nameOf(a), '=>', b)
						favouritesGridView.model.moveRow(a, b)
					}

					function swap(a, b) {
						moveTo(favouritesView.draggedIndex, index)
						if (b < a) { // Dropped before (so the item it was dropped on is to the right)
							moveTo(b+1, a)
						} else if (b > a) { // Dropped after (so the item it was dropped on is to the left)
							moveTo(b-1, a)
						}
					}

					onDrop: {
						// console.log('dropArea.onDrop', favouritesView.draggedIndex, index)
						// console.log('possibleActions', event.possibleActions)
						// console.log('proposedAction', event.proposedAction)

						if (favouritesView.draggedIndex >= 0) { // Moving favorite around.
							// console.log('model.favoriteId', model.favoriteId)
							swap(favouritesView.draggedIndex, index)
						} else { // Add new favorite from dolphin/desktop/taskbar.
							if (event.mimeData.url) {
								// console.log('event.mimeData.url', event.mimeData.url)
								var url = event.mimeData.url.toString()
								var isDesktopUrl = (url.indexOf('file://') === 0) && (url.indexOf('.desktop') === url.length - '.desktop'.length)
								if (isDesktopUrl) {
									// Remove the path because .favoriteId is just the file name.
									// However passing the favoriteId in mimeData.url will prefix the current QML path because it's a QUrl.
									var tokens = event.mimeData.url.toString().split('/')
									var favoriteId = tokens[tokens.length-1]
									appsModel.favoritesModel.addFavorite(favoriteId)
								} else {
									appsModel.favoritesModel.addFavorite(event.mimeData.url)
								}
							}
						}
					}

					onDragEnter: {
						// console.log('dropArea.onDragEnter', index)
					}
				}
			}
			
			property var previousState: null

			model: appsModel.favoritesModel
			onCountChanged: console.log('favouritesView.model.count', count, model)

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
