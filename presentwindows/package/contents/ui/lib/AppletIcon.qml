import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: appletIcon
	property string source: ''
	property bool active: false
	readonly property bool usingPackageSvg: svg.isValid()
	readonly property string filename: source ? plasmoid.file("", "icons/" + source + '.svg') : ""

	PlasmaCore.IconItem {
		anchors.fill: parent
		visible: !appletIcon.usingPackageSvg
		source: appletIcon.usingPackageSvg ? '' : appletIcon.source
		active: appletIcon.active
	}

	PlasmaCore.SvgItem {
		id: svgItem
		anchors.fill: parent
		visible: appletIcon.usingPackageSvg
		svg: PlasmaCore.Svg {
			id: svg
			imagePath: appletIcon.filename
		}
	}
}
