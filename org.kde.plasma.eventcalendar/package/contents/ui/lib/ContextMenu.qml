import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ContextMenu {
	id: contextMenu

	signal populate(var contextMenu)

	// Force loading of MenuItem.qml so dynamic creation *should* be synchronous.
	// It's a property since the default content property of PlasmaComponent.ContextMenu doesn't like it.
	property var menuItemComponent: Component {
		MenuItem {}
	}

	function newSeperator(parentMenu) {
		return newMenuItem(parentMenu, {
			separator: true,
		})
	}

	function newMenuItem(parentMenu, properties) {
		// return menuItemComponent.createObject(parentMenu || contextMenu, properties || {}) // Warns: 'Created graphical object was not placed in the graphics scene'
		return menuItemComponent.createObject(parent, properties || {}) // So attach it to the parent of the ContextMenu (probably bad).
	}

	function newSubMenu(parentMenu, properties) {
		var subMenuItem = newMenuItem(parentMenu || contextMenu, properties)
		var subMenu = Qt.createComponent("ContextMenu.qml").createObject(parentMenu || contextMenu)
		subMenuItem.subMenu = subMenu
		subMenu.visualParent = subMenuItem.action
		return subMenuItem
	}

	function loadMenu() {
		contextMenu.clearMenuItems()
		populate(contextMenu)
	}

	function show(x, y) {
		loadMenu()
		if (content.length > 0) {
			open(x, y)
		}
	}
}
