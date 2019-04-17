import QtQuick 2.0
import org.kde.kirigami 2.0 as Kirigami

// We need to use this pattern in order to use the SystemPalette colors
Canvas {
	contextType: "2d"
	property real size: Math.min(width, height)
	property color fillColor: Kirigami.Theme.textColor
	property int iconSize: 22 // Used for scaling the icon
	readonly property real scale: size/iconSize // Math.floor(size/iconSize)
	property alias path: iconPathSvg.path

	Path {
		id: iconPath
		PathSvg {
			id: iconPathSvg
			// Breeze 22px lock.svg (which symlinks to document-encrypted.svg)
			path: "M 11,3 C 8.784,3 7,4.784 7,7 l 0,4 -2,0 c 0,2.666667 0,5.333333 0,8 4,0 8,0 12,0 l 0,-8 c -0.666667,0 -1.333333,0 -2,0 L 15,7 C 15,4.784 13.216,3 11,3 m 0,1 c 1.662,0 3,1.561 3,3.5 L 14,11 8,11 8,7.5 C 8,5.561 9.338,4 11,4"
		}
	}

	onFillColorChanged: requestPaint()

	onPaint: {
		context.reset()
		context.translate(width/2-size/2, height/2-size/2)
		context.fillStyle = fillColor
		context.scale(scale, scale)
		context.path = iconPath
		context.fill()
	}
}
