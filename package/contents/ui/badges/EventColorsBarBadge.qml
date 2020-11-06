import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: eventColorsBarColor

	Item {
		anchors.left: eventColorsBarColor.left
		anchors.right: eventColorsBarColor.right
		anchors.bottom: eventColorsBarColor.bottom
		height: parent.height / 8
		
		property bool usePadding: !plasmoid.configuration.monthShowBorder
		anchors.leftMargin: usePadding ? parent.width/8 : 0
		anchors.rightMargin: usePadding ? parent.width/8 : 0
		anchors.bottomMargin: usePadding ? parent.height/16 : 0

		RowLayout {
			anchors.fill: parent
			spacing: 0

			Repeater {
				model: dayStyle.useHightlightColor ? [theme.highlightColor] : dayStyle.eventColors

				Rectangle {
					Layout.fillHeight: true
					Layout.fillWidth: true
					color: modelData

					Rectangle {
						anchors.fill: parent
						color: "transparent"
						border.width: 1
						border.color: theme.backgroundColor
						opacity: 0.5
					}
				}
				
			}
		}
	}
}

