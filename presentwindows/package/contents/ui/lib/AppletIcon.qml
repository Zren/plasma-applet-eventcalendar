import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: appletIcon
	property string source: ''
	property bool active: false
	readonly property bool usingPackageSvg: filename // plasmoid.file() returns "" if file doesn't exist.
	readonly property string filename: source ? plasmoid.file("", "icons/" + source + '.svg') : ""
	readonly property int minSize: Math.min(width, height)

	PlasmaCore.IconItem {
		anchors.fill: parent
		visible: !appletIcon.usingPackageSvg
		source: appletIcon.usingPackageSvg ? '' : appletIcon.source
		active: appletIcon.active
	}

	PlasmaCore.SvgItem {
		id: svgItem
		anchors.centerIn: parent
		readonly property real maxSize: Math.min(naturalSize.width, naturalSize.height)
		readonly property real widthRatio: naturalSize.width / maxSize
		readonly property real heightRatio: naturalSize.height / maxSize
		width: appletIcon.minSize * widthRatio
		height: appletIcon.minSize * heightRatio

		visible: appletIcon.usingPackageSvg
		svg: PlasmaCore.Svg {
			id: svg
			imagePath: appletIcon.filename
		}
	}
}
