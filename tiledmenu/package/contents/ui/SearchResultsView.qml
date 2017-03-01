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
	property bool filterViewOpen: false
	
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
		// FlatButton {
		// 	iconName: "globe"
		// 	Layout.preferredHeight: parent.Layout.preferredHeight
		// 	Layout.preferredWidth: parent.Layout.preferredHeight
		// 	onClicked: search.filters = ['bookmarks']
		// 	checked: search.isBookmarksFilter
		// 	checkedEdge: searchView.searchOnTop ?  Qt.TopEdge : Qt.BottomEdge
		// }

		Item { Layout.fillWidth: true }

		FlatButton {
			id: moreFiltersButton
			Layout.preferredHeight: parent.Layout.preferredHeight
			Layout.preferredWidth: moreFiltersButtonRow.implicitWidth + padding*2
			property int padding: (config.searchFilterRowHeight - config.flatButtonIconSize) / 2
			// enabled: false

			RowLayout {
				id: moreFiltersButtonRow
				anchors.centerIn: parent
				anchors.margins: parent.padding
				
				PlasmaComponents.Label {
					id: moreFiltersButtonLabel
					text: i18n("Filters")
				}
				PlasmaCore.IconItem {
					source: "usermenu-down"
					rotation: searchResultsView.filterViewOpen ? 180 : 0
					Layout.preferredHeight: config.flatButtonIconSize
					Layout.preferredWidth: config.flatButtonIconSize

					Behavior on rotation {
						NumberAnimation { duration: units.longDuration }
					}
				}
			}

			onClicked: searchResultsView.filterViewOpen = !searchResultsView.filterViewOpen
		}
	}

	Rectangle {
		color: "#111"
		height: 1
		width: parent.width
		// anchors.bottom: searchFiltersRow.bottom - 1
	}

	

	StackView {
		id: searchResultsViewStackView
		Layout.row: searchView.searchOnTop ? 0 : 2
		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true
		initialItem: searchResultsListScrollView

		Connections {
			target: searchResultsView
			onFilterViewOpenChanged: {
				if (searchResultsView.filterViewOpen) {
					searchResultsViewStackView.push(searchFiltersViewScrollView)
				} else {
					searchResultsViewStackView.pop()
				}
			}
		}

		ScrollView {
			id: searchResultsListScrollView
			visible: false

			SearchResultsList {
				id: searchResultsList
			}
		}

		ScrollView {
			id: searchFiltersViewScrollView
			visible: false

			SearchFiltersView {
				id: searchFiltersView
				width: searchFiltersViewScrollView.viewport.width
			}
		}
		
	}
}
