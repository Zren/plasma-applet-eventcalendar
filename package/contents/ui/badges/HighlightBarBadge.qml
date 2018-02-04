import QtQuick 2.0

Item {
	id: highlightBarBadge

	Rectangle {
		anchors.left: highlightBarBadge.left
		anchors.right: highlightBarBadge.right
		anchors.bottom: parent.bottom
		height: parent.height / 8
		opacity: 0.6
		color: theme.highlightColor
	}
}
