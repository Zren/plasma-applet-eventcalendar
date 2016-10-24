import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

TextField {
	id: panelSearchBox
	placeholderText: {
		if (search.filters == search.defaultFilters) {
			return "Search"
		} else if (search.filters == ['baloosearch']) {
			return "Search Files"
		} else {
			return "Search " + search.filters
		}
	}
	// Layout.fillWidth: true
	// Layout.preferredHeight: 50
	font.pixelSize: 16
	style: TextFieldStyle {
		background: Rectangle {
			color: "#eee"
		}
	}
	onTextChanged: {
		search.query = text
	}
	Connections {
		target: search
		onQueryChanged: panelSearchBox.text = search.query
	}

	property var listView: searchResultsView.listView
	Keys.onPressed: {
		if (event.key == Qt.Key_Up) {
			event.accepted = true; listView.decrementCurrentIndex()
		} else if (event.key == Qt.Key_Down) {
			event.accepted = true; listView.incrementCurrentIndex()
		} else if (event.key == Qt.Key_PageUp) {
			event.accepted = true; listView.currentIndex = Math.max(0, listView.currentIndex - 10)
		} else if (event.key == Qt.Key_PageDown) {
			event.accepted = true; listView.currentIndex = Math.min(listView.currentIndex + 10, listView.count-1)
		} else if (event.key == Qt.Key_Return) {
			event.accepted = true; listView.currentItem.trigger()
		} else if (event.modifiers & Qt.MetaModifier && event.key == Qt.Key_R) {
			event.accepted = true; search.filters = ['shell']
		} else if (event.modifiers & Qt.MetaModifier && event.key == Qt.Key_R) {
			event.accepted = true; search.filters = ['shell']
		}
	}

	Component.onCompleted: {
		forceActiveFocus()
	}
}