import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ColumnLayout {
	id: searchResultsView
	width: 430
	height: 620 - 50
	spacing: 0
	property alias listView: searchResultsList
	
	RowLayout {
		id: searchFiltersRow
		height: 59
		width: 430

		FlatButton {
			iconName: "system-search"
			// height: parent.height
			// width: height
			width: 20
			onClicked: search.applyDefaultFilters()
			checked: search.isDefaultFilter
		}
		FlatButton {
			iconName: "window"
			height: parent.height
			// width: height
			width: 30
			onClicked: search.filters = ['services']
			checked: search.isAppsFilter
		}
		FlatButton {
			iconName: "document-new"
			height: parent.height
			width: height
			onClicked: search.filters = ['baloosearch']
			checked: search.isFileFilter
		}
		FlatButton {
			iconName: "globe"
			height: parent.height
			width: height
			onClicked: search.filters = ['bookmarks']
			checked: search.isBookmarksFilter
		}

		Item { Layout.fillWidth: true }

		PlasmaComponents.ToolButton {
			height: parent.height
			text: "More"
			enabled: false
		}
	}

	Rectangle {
		color: "#111"
		height: 1
		width: 430
		// anchors.bottom: searchFiltersRow.bottom - 1
	}

	ScrollView {
		Layout.fillWidth: true
		Layout.fillHeight: true

		SearchResultsList {
			id: searchResultsList
			anchors.fill: parent
		}
	}
}