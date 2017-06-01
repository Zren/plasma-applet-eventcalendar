// Based on PlasmaStyles.GroupBoxStyle
// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmastyle/GroupBoxStyle.qml

import QtQuick 2.2
import QtQuick.Controls 1.2
import QtQuick.Controls.Private 1.0
import QtQuick.Controls.Styles 1.2 as QtQuickControlStyle
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Style  {
	id: styleRoot

	property color textColor: theme.textColor
	readonly property bool hasLabelRow: control.checkable || control.title

	property Component checkbox: PlasmaComponents.CheckBox {
		checked: control.checked
	}

	property Component panel: Item {
		anchors.fill: parent

		Loader {
			id: checkboxloader
			anchors.left: parent.left
			anchors.leftMargin: styleRoot.padding.left
			sourceComponent: control.checkable ? checkbox : null
			anchors.verticalCenter: label.verticalCenter
			width: item ? item.implicitWidth : 0
			height: item ? label.implicitHeight : 0
		}

		PlasmaComponents.Label {
			id: label
			anchors.top: parent.top
			anchors.left: checkboxloader.right
			// anchors.leftMargin: control.checkable ? units.smallSpacing : 0
			text: control.title
		}

		PlasmaCore.FrameSvgItem {
			id: frame
			anchors.fill: parent
			imagePath: "widgets/frame"
			prefix: "plain"
			visible: !control.flat
			colorGroup: PlasmaCore.ColorScope.colorGroup
			Component.onCompleted: {
				styleRoot.padding.left = frame.margins.left
				styleRoot.padding.top = frame.margins.top + (styleRoot.hasLabelRow ? label.implicitHeight + units.smallSpacing : 0)
				styleRoot.padding.right = frame.margins.right
				styleRoot.padding.bottom = frame.margins.bottom
			}
		}
	}
}
