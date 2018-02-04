import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
	id: eventBadgeCount

	Rectangle {
		// This spams "TypeError: Cannot read property of null" when month is changed...
		// anchors.right: parent.right
		// anchors.bottom: parent.bottom

		// This doesn't ... why?!
		anchors.right: eventBadgeCount.right
		anchors.bottom: eventBadgeCount.bottom

		height: parent.height / 3
		width: eventBadgeCountText.width
		color: {
			if (plasmoid.configuration.show_outlines) {
				var c = Qt.darker(theme.backgroundColor, 1); // Cast to color
				c.a = 0.6; // 60%
				return c;
			} else {
				return "transparent";
			}
		}

		PlasmaComponents.Label {
			id: eventBadgeCountText
			height: parent.height
			width: Math.max(paintedWidth, height)
			anchors.centerIn: parent

			color: theme.highlightColor
			text: modelEventsCount
			font.weight: Font.Bold
			font.pointSize: 1024
			fontSizeMode: Text.VerticalFit
			wrapMode: Text.NoWrap

			horizontalAlignment: Text.AlignHCenter
			verticalAlignment: Text.AlignVCenter
			smooth: true
		}
	}
}

