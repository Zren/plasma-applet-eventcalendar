import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.draganddrop 2.0 as DragAndDrop

Rectangle {
	id: tileItemView
	color: appObj.backgroundColor

	readonly property int smallIconSize: 32 * units.devicePixelRatio
	readonly property int mediumIconSize: 72 * units.devicePixelRatio
	readonly property int largeIconSize: 96 * units.devicePixelRatio

	readonly property int tileLabelAlignment: Text.AlignLeft

	property bool hovered: false

	states: [
		State {
			when: modelData.w == 1 && modelData.h >= 1
			PropertyChanges { target: icon; size: smallIconSize }
			PropertyChanges { target: label; visible: false }
		},
		State {
			when: modelData.w >= 2 && modelData.h == 1
			AnchorChanges { target: icon
				anchors.horizontalCenter: undefined
				anchors.left: tileItemView.left
			}
			PropertyChanges { target: icon; anchors.leftMargin: 4 }
			AnchorChanges { target: label
				anchors.verticalCenter: tileItemView.verticalCenter
				anchors.left: icon.right
				anchors.bottom: undefined
				anchors.right: tileItemView.right
			}
		},
		State {
			when: modelData.w == 2 && modelData.h == 2
			PropertyChanges { target: icon; size: mediumIconSize }
		},
		State {
			when: modelData.w == 4 && modelData.h == 2
			PropertyChanges { target: icon; size: mediumIconSize }
		},
		State {
			when: modelData.w == 4 && modelData.h == 4
			PropertyChanges { target: icon; size: largeIconSize }
		}
	]

	Image {
		id: backgroundImage
		anchors.fill: parent
		visible: appObj.backgroundImage
		source: appObj.backgroundImage
		fillMode: Image.PreserveAspectCrop
		asynchronous: true
	}

	PlasmaCore.IconItem {
		id: icon
		visible: appObj.showIcon
		source: appObj.iconSource
		anchors.verticalCenter: parent.verticalCenter
		anchors.horizontalCenter: parent.horizontalCenter
		// property int size: 72 // Just a default, overriden in State change
		property int size: Math.min(parent.width, parent.height) / 2
		width: appObj.showIcon ? size : 0
		height: appObj.showIcon ? size : 0
		anchors.fill: appObj.iconFill ? parent : null
		smooth: appObj.iconFill
	}

	PlasmaComponents.Label {
		id: label
		visible: appObj.showLabel
		text: appObj.labelText
		anchors.leftMargin: 4
		anchors.left: parent.left
		anchors.bottom: parent.bottom
		anchors.right: parent.right
		anchors.rightMargin: 4
		wrapMode: Text.Wrap
		horizontalAlignment: tileLabelAlignment
		width: parent.width
		font.pointSize: 10
		renderType: Text.QtRendering // Fix pixelation when scaling. Plasma.Label uses NativeRendering.
		style: Text.Outline
		styleColor: tileItemView.color
	}
}
