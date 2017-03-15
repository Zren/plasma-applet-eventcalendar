import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmacomponents/qmenu.cpp
// Example: https://github.com/KDE/plasma-desktop/blob/master/applets/taskmanager/package/contents/ui/ContextMenu.qml
PlasmaComponents.ContextMenu {
	id: contextMenu

	function newSeperator() {
		return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu);
	}
	function newMenuItem() {
		return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu);
	}

	property bool clearBeforeOpen: true
	signal beforeOpen(var menu)

	function doBeforeOpen() {
		if (clearBeforeOpen) {
			clearMenuItems()
		}
		beforeOpen(contextMenu)
	}

	function show(x, y) {
		doBeforeOpen()
		open(x, y)
	}

	function showRelative() {
		doBeforeOpen()
		openRelative()
	}

	function showBelow(item) {
		visualParent = item
		placement = PlasmaCore.Types.BottomPosedLeftAlignedPopup
		showRelative()
	}
}
