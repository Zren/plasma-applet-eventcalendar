import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.plasma.private.kicker 0.1 as Kicker
import org.kde.kquickcontrolsaddons 2.0

MouseArea {
	id: tileGrid

	hoverEnabled: true
	property bool isDragging: cellRepeater.dropping

	property int cellSize: 60 * units.devicePixelRatio
	property real cellMargin: 3 * units.devicePixelRatio
	property real cellPushedMargin: 6 * units.devicePixelRatio
	property int cellBoxSize: cellMargin + cellSize + cellMargin
	property int hoverOutlineSize: 6 * units.devicePixelRatio

	property int minColumns: Math.floor(width / cellBoxSize)
	property int minRows: Math.floor(height / cellBoxSize)

	property int maxColumn: 0
	property int maxRow: 0
	property int maxWidth: 0
	property int maxHeight: 0
	property int columns: Math.max(minColumns, maxColumn)
	property int rows: Math.max(minRows, maxRow)

	property var addedItem: null
	readonly property bool adding: addedItem
	property int draggedIndex: -1
	readonly property var draggedItem: draggedIndex >= 0 ? tileModel[draggedIndex] : null
	property bool editing: isDragging && draggedItem || adding
	property int dropHoverX: -1
	property int dropHoverY: -1
	readonly property int dropWidth: draggedItem ? draggedItem.w : addedItem ? addedItem.w : 0
	readonly property int dropHeight: draggedItem ? draggedItem.h : addedItem ? addedItem.h : 0
	property bool canDrop: false
	function resetDrag() {
		dropHoverX = -1
		dropHoverY = -1
		cellRepeater.dropping = false
		draggedIndex = -1
		addedItem = null
	}
	function startDrag(index) {
		draggedIndex = index
		dropHoverX = draggedItem.x
		dropHoverY = draggedItem.y
		cellRepeater.dropping = true
	}

	property color tileDefaultBackgroundColor: config.defaultTileColor

	property var hitBox: [] // hitBox[y][x]
	function updateSize() {
		var c = 0;
		var r = 0;
		var w = 1;
		var h = 1;
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			c = Math.max(c, tile.x + tile.w)
			r = Math.max(r, tile.y + tile.h)
			w = Math.max(w, tile.w)
			h = Math.max(h, tile.h)
		}
		// Add extra rows when dragging so we can drop scrolled down
		if (draggedItem) {
			// c += draggedItem.w
			r += draggedItem.h
		}

		// Rebuild hitBox
		var hbColumns = Math.max(minColumns, c)
		var hbRows = Math.max(minRows, r)
		var hb = new Array(hbRows)
		for (var i = 0; i < hbRows; i++) {
			hb[i] = new Array(hbColumns)
		}
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (i == draggedIndex) {
				continue;
			}
			for (var j = tile.y; j < tile.y + tile.h; j++) {
				for (var k = tile.x; k < tile.x + tile.w; k++) {
					hb[j][k] = true
				}
			}
		}

		// Update Properties
		hitBox = hb
		maxColumn = c
		maxRow = r
		maxWidth = w
		maxHeight = h
	}
	function update() {
		var urlList = []
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tile.url) {
				urlList.push(tile.url)
			}
		}
		appsModel.tileGridModel.favorites = urlList
		updateSize()
	}
	onDraggedItemChanged: update()
	onTileModelChanged: update()
	property var tileModel: []


	function hits(x, y, w, h) {
		// console.log('hits', [columns,rows], [x,y,w,h], hitBox)
		for (var j = y; j < y + h; j++) {
			if (j < 0 || j >= hitBox.length) {
				continue; // Should we return true when out of bounds?
			}
			for (var k = x; k < x + w; k++) {
				if (k < 0 || k >= hitBox[j].length) {
					continue; // Should we return true when out of bounds?
				}
				if (hitBox[j][k]) {
					return true
				}
			}
		}
		return false
	}


	ScrollView {
		id: scrollView
		anchors.fill: parent

		readonly property int scrollTop: flickableItem ? flickableItem.contentY : 0
		readonly property int scrollHeight: flickableItem ? flickableItem.contentHeight : 0
		readonly property int scrollTopAtBottom: viewport ? scrollHeight - viewport.height : 0
		readonly property bool scrollAtTop: scrollTop == 0
		readonly property bool scrollAtBottom: scrollTop >= scrollTopAtBottom

		function scrollBy(deltaY) {
			if (flickableItem) {
				// console.log('scrollHeight', scrollTopAtBottom, scrollHeight, viewport.height)
				flickableItem.contentY = Math.max(0, Math.min(scrollTop + deltaY, scrollTopAtBottom))
			}
		}

		__wheelAreaScrollSpeed: cellBoxSize
		style: ScrollViewStyle {
			transientScrollBars: true
		}
		
		Item {
			id: scrollItem

			width: columns * cellBoxSize
			height: rows * cellBoxSize

			// Rectangle {
			// 	anchors.fill: parent
			// 	color: "#88336699"
			// }

			Repeater {
				id: cellRepeater
				property int cellCount: columns * rows
				property bool dropping: false
				onCellCountChanged: {
					if (!dropping) {
						model = cellCount
					}
				}
				model: 0

				Item {
					id: cellItem
					property int modelX: modelData % columns
					property int modelY: Math.floor(modelData / columns)
					x: modelX * cellBoxSize
					y: modelY * cellBoxSize
					width: cellBoxSize
					height: cellBoxSize

					property bool hovered: {
						if (tileGrid.editing) {
							return dropHoverX <= modelX && modelX < dropHoverX + dropWidth && dropHoverY <= modelY && modelY < dropHoverY + dropHeight
						} else {
							return false
						}
					}

					Rectangle {
						anchors.fill: parent
						anchors.margins: cellMargin
						color: {
							if (cellItem.hovered) {
								if (canDrop) {
									return "#88336699"
								} else {
									return "#88880000"
								}
							} else {
								return "transparent"
							}
						}
						border.width: 1
						border.color: tileGrid.editing ? "#44000000" : "transparent"
					}


					// DragAndDrop.DropArea {
					DropArea {
						id: cellDropArea
						anchors.fill: parent

						// onDrop: {
						onDropped: {
							// console.log('onDrop', JSON.stringify(draggedItem))
							if (draggedItem) {
								draggedItem.x = dropHoverX
								draggedItem.y = dropHoverY
								tileGrid.tileModelChanged()
								tileGrid.resetDrag()
								// event.accept(Qt.MoveAction)
							} else if (addedItem) {
								addedItem.x = dropHoverX
								addedItem.y = dropHoverY
								tileGrid.tileModel.push(addedItem)
								tileGrid.tileModelChanged()
								tileGrid.resetDrag()
							}

							
						}
						function parseDropUrl(url) {
							var workingDir = Qt.resolvedUrl('.')
							var endsWithDesktop = url.indexOf('.desktop') === url.length - '.desktop'.length
							var isRelativeDesktopUrl = endsWithDesktop && (
								url.indexOf(workingDir) === 0
								// || url.indexOf('file:///usr/share/applications/') === 0
								// || url.indexOf('/.local/share/applications/') >= 0
								|| url.indexOf('/share/applications/') >= 0 // 99% certain this desktop file should be accessed relatively.
							)
							console.log('parseDropUrl', workingDir, endsWithDesktop, isRelativeDesktopUrl)
							console.log('[tiledmenu] onUrlDropped', 'url', url)
							if (isRelativeDesktopUrl) {
								// Remove the path because .favoriteId is just the file name.
								// However passing the favoriteId in mimeData.url will prefix the current QML path because it's a QUrl.
								var tokens = url.toString().split('/')
								var favoriteId = tokens[tokens.length-1]
								console.log('isRelativeDesktopUrl', tokens, favoriteId)
								return favoriteId
							} else {
								return url
							}
						}
						// onDragEnter: {
						onEntered: {
							// http://doc.qt.io/qt-5/qml-qtquick-dragevent.html
							// console.log('onDragEnter', modelX, modelY)
							if (draggedItem) {
							} else if (addedItem) {
							} else if (drag.hasUrls) {
								var url = drag.urls[0]
								url = parseDropUrl(url)

								addedItem = newTile(url)
								dropHoverX = modelX
								dropHoverY = modelY

								for (var i = 0; i < drag.keys.length; i++) {
									var key = drag.keys[i]
									console.log('drop => addItem', key, drag.getDataAsString(key))
								}

								// Add new favorite from dolphin/desktop/taskbar.
								// var favoriteId = favouritesGridView.parseDropUrl(event)
							} else {
								return
							}

							dropHoverX = Math.min(modelX, columns - dropWidth)
							dropHoverY = modelY
							canDrop = !hits(dropHoverX, dropHoverY, dropWidth, dropHeight)
						}
					}
				}
			}

			Repeater {
				id: tileModelRepeater
				model: tileModel
				// onCountChanged: console.log('onCountChanged', count)
				
				TileItem {
					id: tileItem
				}
				
			}
		}
	}

	/* Scroll on hover with drag */
	property int scrollAreaTickDelta: cellBoxSize
	property int scrollAreaTickInterval: 200
	property int scrollAreaSize: Math.min(cellBoxSize * 1.5, scrollView.height / 5) // 20vh or 90pt

	// Plasma's DropArea requires you to exit the area and reenter for the drop to take.
	// Qt's DropArea only requires the mouse to move for the cellRepeater's DropArea to detect the drag.
	DropArea {
		id: scrollUpArea
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		height: scrollAreaSize
		enabled: !scrollView.scrollAtTop
		property bool ticking: enabled && containsDrag

		Timer {
			id: scrollUpTicker
			interval: scrollAreaTickInterval
			repeat: true
			running: parent.ticking
			onTriggered: {
				scrollView.scrollBy(-scrollAreaTickDelta)
			}
		}

		Rectangle {
			anchors.fill: parent
			opacity: parent.ticking ? 1 : 0
			gradient: Gradient {
				GradientStop { position: 0.0; color: theme.highlightColor }
				GradientStop { position: 0.3; color: "transparent" }
			}
		}
	}

	DropArea {
		id: scrollDownArea
		anchors.left: parent.left
		anchors.right: parent.right
		anchors.bottom: parent.bottom
		height: scrollAreaSize
		enabled: !scrollView.scrollAtBottom
		property bool ticking: enabled && containsDrag

		Timer {
			id: scrollDownTicker
			interval: scrollAreaTickInterval
			repeat: true
			running: parent.ticking
			onTriggered: {
				scrollView.scrollBy(scrollAreaTickDelta)
			}
		}

		Rectangle {
			anchors.fill: parent
			opacity: parent.ticking ? 1 : 0
			gradient: Gradient {
				GradientStop { position: 0.7; color: "transparent" }
				GradientStop { position: 1.0; color: theme.highlightColor }
			}
		}
	}

	function newTile(url) {
		return {
			"x": 0,
			"y": 0,
			"w": 2,
			"h": 2,
			"url": url,
		}
	}

	function removeIndex(i) {
		tileModel.splice(i, 1) // remove 1 item at index
		tileModelChanged()
	}

	function removeApp(url) {
		var removedCount = 0
		for (var i = tileModel.length - 1; i >= 0; i--) {
			var tile = tileModel[i]
			if (tile.url == url) {
				removedCount += 1
				tileModel.splice(i, 1) // remove 1 item at index
			}
		}
		if (removedCount > 0) {
			tileModelChanged()
		}
	}

	function addTile(tile) {
		tileModel.push(tile)
		tileModelChanged()
	}

	function findOpenPos(w, h) {
		for (var y = 0; y < rows; y++) {
			for (var x = 0; x < columns - (w-1); x++) {
				if (hitBox[y][x])
					continue

				if (hits(x, y, w, h))
					continue

				// Room open for
				return {
					x: x,
					y: y,
				}
			}
		}

		// Current grid has no room.
		// Add to new row.
		return {
			x: 0,
			y: rows
		}
	}

	function addApp(url, x, y) {
		var tile = newTile(url)
		if (typeof x !== "undefined" && typeof y !== "undefined") {
			tile.x = x
			tile.y = y
		} else {
			var openPos = findOpenPos(tile.w, tile.h)
			tile.x = openPos.x
			tile.y = openPos.y
		}
		tileModel.push(tile)
		tileModelChanged()
	}

	function hasAppTile(url) {
		for (var i = 0; i < tileModel.length; i++) {
			var tile = tileModel[i]
			if (tile.url == url) {
				return true
			}
		}
		return false
	}

	signal editTile(var tile)
	// function editTile(tile) {
	// 	searchView.tileEditorView.open(tile)
	// }
}
