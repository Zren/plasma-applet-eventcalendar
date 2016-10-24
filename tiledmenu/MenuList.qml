import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

FocusScope {
	id: menuList
	property alias model: listView.model
	property alias currentIndex: listView.currentIndex
	Layout.fillWidth: true
	height: childrenRect.height

	ListView {
		id: listView
		// Layout.fillWidth: true
		width: parent.width
		height: childrenRect.height

		boundsBehavior: Flickable.StopAtBounds
		snapMode: ListView.SnapToItem
		spacing: 0

		currentIndex: -1
		onCountChanged: currentIndex = -1
		onCurrentIndexChanged: {
			if (currentIndex != - 1) {
				listView.forceActiveFocus();
			}
		}

		delegate: PlasmaComponents.ListItem {
			PlasmaComponents.Label {
				text: label
			}
		}
		highlight: PlasmaComponents.Highlight {
			anchors.fill: listView.currentItem;

			visible: listView.currentItem && !listView.currentItem.isSeparator
		}


		Keys.onPressed: {
			if (event.key == Qt.Key_Up) {
				if (listView.currentIndex == 0) {
					menuList.navigateUp();
					event.accepted = true;
				}
			} else if (event.key == Qt.Key_Down) {
				if (listView.currentIndex == listView.count - 1) {
					menuList.navigateDown();
					event.accepted = true;
				}
			} else {
				if (event.text != "") {
					search.query += event.text;
					panelSearchBox.focus = true;
				}
			}
		}
	}

	// onFocusChanged: {
	// 	if (!focus) {
	// 		listView.currentIndex = -1
	// 	}
	// }

	function navigateToTop() {
		if (visible && listView.count > 0) {
			listView.currentIndex = 0
		} else {
			navigateDown();
		}
	}

	function navigateToBottom() {
		if (visible && listView.count > 0) {
			listView.currentIndex = listView.count - 1;
		} else {
			navigateUp();
		}
	}

	function navigateUp() {
		if (keyNavUp) {
			if (typeof keyNavUp.navigateToBottom === 'function') {
				keyNavUp.navigateToBottom();
			} else {
				keyNavUp.focus = true;
			}
			listView.currentIndex = -1;
		}
	}

	function navigateDown() {
		if (keyNavDown) {
			if (typeof keyNavDown.navigateToTop === 'function') {
				keyNavDown.navigateToTop();
			} else {
				keyNavDown.focus = true;
			}
			listView.currentIndex = -1;
		}
	}


	property var keyNavUp: null
	property var keyNavLeft: null
	property var keyNavDown: null
	property var keyNavRight: null
}
