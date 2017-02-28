import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

GridLayout {
	id: searchResultsView
	rowSpacing: 0
	property alias listView: searchResultsList
	
	RowLayout {
		id: searchFiltersRow
		Layout.row: searchView.searchOnTop ? 2 : 0
		Layout.preferredHeight: config.searchFilterRowHeight - 1 // -1px is for the underline seperator
		Layout.fillWidth: true

		FlatButton {
			iconName: "system-search-symbolic"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.applyDefaultFilters()
			checked: search.isDefaultFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		FlatButton {
			iconName: "window"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.filters = ['services']
			checked: search.isAppsFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		FlatButton {
			iconName: "document-new"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.filters = ['baloosearch']
			checked: search.isFileFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}
		FlatButton {
			iconName: "globe"
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: parent.Layout.preferredHeight
			onClicked: search.filters = ['bookmarks']
			checked: search.isBookmarksFilter
			checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		}

		Item { Layout.fillWidth: true }

		PlasmaComponents.ToolButton {
			Layout.preferredHeight: parent.Layout.preferredHeight
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
		Layout.row: searchView.searchOnTop ? 0 : 2
		Layout.fillWidth: true
		Layout.fillHeight: true

		SearchResultsList {
			id: searchResultsList
			anchors.fill: parent
		}
	}
}