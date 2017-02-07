import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

// appendDropArea needs to wrap the entire scrollview.
// It cannot be a sibling since it will steal focus from
// the gridview DropAreas since it's not a parent and will not detect
// that it needs to "leave" the appendDropArea.
// See: https://github.com/KDE/kdeclarative/blob/master/src/qmlcontrols/draganddrop/DeclarativeDropArea.cpp#L42
DragAndDrop.DropArea {
	// id: appendDropArea
	id: favouritesView

	width: config.favViewDefaultWidth
	height: config.defaultHeight

	property bool editing: draggedItem
	property QtObject draggedItem: null
	property int draggedIndex: -1

	function editTile(favoriteId, favouritesItem) {
		searchView.tileEditorView.open(favoriteId, favouritesItem)
	}

	function closeTileEditor() {
		searchView.tileEditorView.close()
	}

	onDrop: {
		if (favouritesView.draggedIndex >= 0) { // Moving favorite around (to the end).
			favouritesGridView.swap(favouritesView.draggedIndex, favouritesGridView.model.count - 1)
			event.accept(Qt.MoveAction)
		} else { // Add new favorite from dolphin/desktop/taskbar (to the end).
			var favoriteId = favouritesGridView.parseDropUrl(event)
			favouritesGridView.append(favoriteId)
			event.accept(Qt.CopyAction)
		}
	}

	onDragEnter: {
		// console.log('appendDropArea.onDragEnter')
	}

	ScrollView {
		id: favouritesScrollView
		anchors.fill: parent

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

				delegate: FavouriteItem {
					id: item
				}
				
				property var previousState: null

				model: appsModel.favoritesModel
				onCountChanged: console.log('favouritesView.model.count', count, model)

				// function nameOf(i) {
				// 	return favouritesGridView.model.data(favouritesGridView.model.index(i, 0), Qt.DisplayRole)
				// }

				function parseDropUrl(event) {
					// console.log('[tiledmenu] onUrlDropped', 'mimeData', event.mimeData)
					// console.log('[tiledmenu] onUrlDropped', 'mimeData', Object.keys(event.mimeData))
					// console.log('[tiledmenu] onUrlDropped', 'mimeData.mimeData', event.mimeData.mimeData)
					// console.log('[tiledmenu] onUrlDropped', 'mimeData', event.mimeData)
					// console.log('[tiledmenu] onUrlDropped', 'widget.draggedFavoriteId', widget.draggedFavoriteId)
					if (widget.draggedFavoriteId) {
						var favoriteId = widget.draggedFavoriteId
						console.log('[tiledmenu] onWidgetDraggedFavoriteIdDropped', 'favoriteId', favoriteId)
						return favoriteId
					} else if (event.mimeData.mimeData && event.mimeData.mimeData.favoriteId) {
						// Eventually we should be able to get the favoriteId from the MimeData, but right now we can't access non-default MimeData keys.
						// https://github.com/KDE/kdeclarative/blob/0e47f91b3a2c93655f25f85150faadad0d65d2c1/src/qmlcontrols/draganddrop/DeclarativeDragDropEvent.cpp#L66
						var favoriteId = event.mimeData.mimeData.favoriteId
						console.log('[tiledmenu] onFavoriteIdDropped', 'favoriteId', favoriteId)
						return favoriteId
					} else if (event.mimeData.url) {
						// console.log('event.mimeData.url', event.mimeData.url)
						var url = event.mimeData.url.toString()
						var workingDir = Qt.resolvedUrl('.')
						var endsWithDesktop = url.indexOf('.desktop') === url.length - '.desktop'.length
						var isRelativeDesktopUrl = endsWithDesktop && (
							url.indexOf(workingDir) === 0
							// || url.indexOf('file:///usr/share/applications/') === 0
							// || url.indexOf('/.local/share/applications/') >= 0
							|| url.indexOf('/share/applications/') >= 0 // 99% certain this desktop file should be accessed relatively.
						)
						console.log('[tiledmenu] onUrlDropped', 'url', url)
						if (isRelativeDesktopUrl) {
							// Remove the path because .favoriteId is just the file name.
							// However passing the favoriteId in mimeData.url will prefix the current QML path because it's a QUrl.
							var tokens = event.mimeData.url.toString().split('/')
							var favoriteId = tokens[tokens.length-1]
							return favoriteId
						} else {
							return event.mimeData.url
						}
					} else {
						return "" // Will be ignored when added
					}
				}

				function append(favoriteId) {
					appsModel.favoritesModel.addFavorite(favoriteId)
				}

				function insert(index, favoriteId) {
					appsModel.favoritesModel.addFavorite(favoriteId, index)
				}

				function moveTo(a, b) {
					// console.log(nameOf(a), '=>', b)
					favouritesGridView.model.moveRow(a, b)
				}

				function swap(a, b) {
					moveTo(a, b)
					if (b < a) { // Dropped before (so the item it was dropped on is to the right)
						moveTo(b+1, a)
					} else if (b > a) { // Dropped after (so the item it was dropped on is to the left)
						moveTo(b-1, a)
					}
				}

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
	} // ScrollView

} // DropArea
