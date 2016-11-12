import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

FlatButton {
	width: parent.width
	height: config.flatButtonSize
	property var sidebarMenu: parent.parent // Column.SidebarMenu
	property bool expanded: sidebarMenu.open
	labelVisible: expanded
	property bool closeOnClick: true

	onClicked: {
		if (sidebarMenu.open && closeOnClick) {
			sidebarMenu.open = false
		}
	}
}