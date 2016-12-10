import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ColumnLayout {
	id: searchResultsView
	width: config.appListWidth
	height: config.defaultHeight - config.searchFieldHeight
	spacing: 0
	property alias listView: searchResultsList
	
	RowLayout {
		id: searchFiltersRow
		height: config.flatButtonSize - 1 // -1px is for the underline seperator
		width: parent.width

		FlatButton {
			iconName: "system-search-symbolic"
			// height: parent.height
			// width: height
			width: 20
			onClicked: search.applyDefaultFilters()
			checked: search.isDefaultFilter
			checkedEdge: Qt.BottomEdge
		}
		FlatButton {
			iconName: "window"
			height: parent.height
			// width: height
			width: 30
			onClicked: search.filters = ['services']
			checked: search.isAppsFilter
			checkedEdge: Qt.BottomEdge
		}
		FlatButton {
			iconName: "document-new"
			height: parent.height
			width: height
			onClicked: search.filters = ['baloosearch']
			checked: search.isFileFilter
			checkedEdge: Qt.BottomEdge
		}
		FlatButton {
			iconName: "globe"
			height: parent.height
			width: height
			onClicked: search.filters = ['bookmarks']
			checked: search.isBookmarksFilter
			checkedEdge: Qt.BottomEdge
		}

		Item { Layout.fillWidth: true }

		PlasmaComponents.ToolButton {
			height: parent.height
			text: i18n("More")
			enabled: false
		}
	}

	Rectangle {
		color: "#111"
		height: 1
		width: parent.width
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