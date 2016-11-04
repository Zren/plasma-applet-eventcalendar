import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate

MouseArea {
	id: control
	hoverEnabled: true
	// width: 200
	// height: 200

	property alias hovered: control.containsMouse
	property string iconName: ""
	property string text: ""
	property string tooltip: ""


	property font font: theme.defaultFont
	property alias iconSource: control.iconName
	property real minimumWidth: 0
	property real minimumHeight: 0
	property bool flat: true

	ButtonShadow {
		id: shadow
		visible: control.activeFocus
		anchors.fill: parent
		enabledBorders: surfaceNormal.enabledBorders
		state: {
			if (control.pressed) {
				return "hidden"
			} else if (control.containsMouse) {
				return "hover"
			} else if (control.activeFocus) {
				return "focus"
			} else {
				return "shadow"
			}
		}
	}
	PlasmaCore.Svg {
		id: bordersSvg
		imagePath: "widgets/button"
	}
	PlasmaCore.FrameSvgItem {
		id: surfaceNormal
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "normal"
		enabledBorders: "AllBorders"
	}
	PlasmaCore.FrameSvgItem {
		id: surfacePressed
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "pressed"
		enabledBorders: surfaceNormal.enabledBorders
		opacity: 0
	}

	state: (control.pressed || control.checked ? "pressed" : (control.containsMouse ? "hover" : "normal"))

	states: [
		State { name: "normal"
			PropertyChanges {
				target: surfaceNormal
				opacity: 0
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 0
			}
		},
		State { name: "hover"
			PropertyChanges {
				target: surfaceNormal
				opacity: 1
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 0
			}
		},
		State { name: "pressed"
			PropertyChanges {
				target: surfaceNormal
				opacity: 0
			}
			PropertyChanges {
				target: surfacePressed
				opacity: 1
			}
		}
	]

	transitions: [
		Transition {
			//Cross fade from pressed to normal
			ParallelAnimation {
				NumberAnimation { target: surfaceNormal; property: "opacity"; duration: 100 }
				NumberAnimation { target: surfacePressed; property: "opacity"; duration: 100 }
			}
		}
	]

	// property alias padding: padding
	// Item {
	// 	id: padding
	// 	property alias top: label.margins.top
	// }

	Item {
		// id: buttonLabel
		anchors.fill: parent
		anchors.topMargin: surfaceNormal.margins.top
		anchors.leftMargin: surfaceNormal.margins.left
		anchors.rightMargin: surfaceNormal.margins.right
		anchors.bottomMargin: surfaceNormal.margins.bottom

		// Rectangle {
		// 	color: "red"
		// 	anchors.fill: parent
		// }
		
		// implicitHeight: buttonContent.Layout.preferredHeight
		// implicitWidth: buttonContent.implicitWidth

		RowLayout {
			id: buttonContent
			anchors.fill: parent
			spacing: units.smallSpacing

			Layout.preferredHeight: Math.max(units.iconSizes.small, label.implicitHeight)

			PlasmaCore.IconItem {
				id: icon
				source: control.iconName || control.iconSource
				anchors.verticalCenter: parent.verticalCenter

				implicitHeight: label.implicitHeight
				implicitWidth: implicitHeight

				Layout.minimumWidth: valid ? parent.height: 0
				Layout.maximumWidth: Layout.minimumWidth
				visible: valid
				Layout.minimumHeight: Layout.minimumWidth
				Layout.maximumHeight: Layout.minimumWidth
				Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
				active: control.containsMouse
				colorGroup: control.containsMouse ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
			}

			PlasmaComponents.Label {
				id: label
				Layout.minimumWidth: implicitWidth
				text: QtQuickControlsPrivate.StyleHelpers.stylizeMnemonics(control.text)
				font: control.font || theme.defaultFont
				visible: control.text != ""
				Layout.fillWidth: true
				height: parent.height
				color: control.containsMouse ? theme.buttonTextColor : PlasmaCore.ColorScope.textColor
				horizontalAlignment: icon.valid ? Text.AlignLeft : Text.AlignHCenter
				verticalAlignment: Text.AlignVCenter
				elide: Text.ElideRight
			}
		}
	}
}
