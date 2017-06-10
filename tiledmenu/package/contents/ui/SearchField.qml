import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

TextField {
	id: searchField
	placeholderText: {
		if (search.isDefaultFilter) {
			return i18n("Search")
		} else if (search.isAppsFilter) {
			return i18n("Search Apps")
		} else if (search.isFileFilter) {
			return i18n("Search Files")
		} else if (search.isBookmarksFilter) {
			return i18n("Search Bookmarks")
		} else {
			return i18nc("Search [krunnerName, krunnerName, ...], ", "Search %1", search.filters)
		}
	}
	property int topMargin: 0
	property int bottomMargin: 0
	property int defaultFontSize: 16 * units.devicePixelRatio // Not the same as pointSize=16
	property int styleMaxFontSize: height - topMargin - bottomMargin
	font.pixelSize: Math.min(defaultFontSize, styleMaxFontSize)

	style: plasmoid.configuration.searchFieldFollowsTheme ? plasmaStyle : redmondStyle
	Component {
		id: plasmaStyle
		// Creates the following warning when not in use:
		//   file:///usr/lib/x86_64-linux-gnu/qt5/qml/QtQuick/Controls/Styles/Plasma/TextFieldStyle.qml:74: ReferenceError: textField is not defined
		// Caused by:
		//   var actionIconSize = Math.max(textField.height * 0.8, units.iconSizes.small);
		PlasmaStyles.TextFieldStyle {
			id: style
			Component.onCompleted: {
				searchField.topMargin = Qt.binding(function() {
					return style.padding.top
				})
				searchField.bottomMargin = Qt.binding(function() {
					return style.padding.bottom
				})
			}
		}
	}
	Component {
		id: redmondStyle

		// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Styles/Base/TextFieldStyle.qml
		// https://github.com/qt/qtquickcontrols/blob/dev/src/controls/Styles/Desktop/TextFieldStyle.qml
		TextFieldStyle {
			id: style
			
			background: Rectangle {
				color: "#eee"
			}
			textColor: "#111"
			placeholderTextColor: "#777"

			Component.onCompleted: {
				searchField.topMargin = Qt.binding(function() {
					return style.padding.top
				})
				searchField.bottomMargin = Qt.binding(function() {
					return style.padding.bottom
				})
			}
		}
	}

	onTextChanged: {
		search.query = text
	}
	Connections {
		target: search
		onQueryChanged: searchField.text = search.query
	}

	property var listView: searchResultsView.listView
	Keys.onPressed: {
		if (event.key == Qt.Key_Up) {
			event.accepted = true; listView.goUp()
		} else if (event.key == Qt.Key_Down) {
			event.accepted = true; listView.goDown()
		} else if (event.key == Qt.Key_PageUp) {
			event.accepted = true; listView.pageUp()
		} else if (event.key == Qt.Key_PageDown) {
			event.accepted = true; listView.pageDown()
		} else if (event.key == Qt.Key_Return) {
			event.accepted = true; listView.currentItem.trigger()
		} else if (event.modifiers & Qt.MetaModifier && event.key == Qt.Key_R) {
			event.accepted = true; search.filters = ['shell']
		} else if (event.modifiers & Qt.MetaModifier && event.key == Qt.Key_R) {
			event.accepted = true; search.filters = ['shell']
		} else if (event.key == Qt.Key_Escape) {
			plasmoid.expanded = false
		}
	}

	Component.onCompleted: {
		forceActiveFocus()
	}
}