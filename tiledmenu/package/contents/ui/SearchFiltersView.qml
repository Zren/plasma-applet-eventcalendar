import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


ColumnLayout {
	id: searchFiltersView
	// width: parent.width
	// Layout.fillHeight: true

	SearchFiltersViewItem {
		runnerId: ""
		indentLevel: 0
		iconSource: "applications-other"
		text: i18n("All") + ' (Not working)'
		subText: i18n("Search with all KRunner plugins")
		checkBox.visible: false
		onApplyButtonClicked: search.filters = []
		enabled: false
	}

	SearchFiltersViewItem {
		runnerId: ""
		indentLevel: 0
		iconSource: "applications-other"
		text: i18n("Default")
		subText: i18n("Search with user selected defaults")
		checkBox.visible: false
		onApplyButtonClicked: search.applyDefaultFilters()
	}

	// Installed runners are listed at: /usr/share/kservices5/plasma-runner-*.desktop

	SearchFiltersViewItem {
		runnerId: "services"
		indentLevel: 1
		iconSource: "window"
		text: i18n("Applications")
	}

	SearchFiltersViewItem {
		runnerId: "baloosearch"
		indentLevel: 1
		iconSource: "document-new"
		text: i18n("Files")
	}

	//--- baloosearch filters
	// https://github.com/KDE/baloo/blob/master/docs/user/searching.md#advanced-searches
	// Use `type:Audio` or `type:Document` to filter specific filetypes.
	SearchFiltersViewItem {
		runnerId: "baloosearch"
		indentLevel: 2
		iconSource: "folder-music-symbolic"
		text: i18n("Music")
		checkBox.visible: false
		onApplyButtonClicked: search.setQueryPrefix('type:Audio ')
	}
	SearchFiltersViewItem {
		runnerId: "baloosearch"
		indentLevel: 2
		iconSource: "folder-videos-symbolic"
		text: i18n("Videos")
		checkBox.visible: false
		onApplyButtonClicked: search.setQueryPrefix('type:Video ')
	}
	//--- end baloosearch filters

	SearchFiltersViewItem {
		runnerId: "bookmarks"
		indentLevel: 1
		iconSource: "globe"
		text: i18n("Bookmarks")
	}

	SearchFiltersViewItem {
		runnerId: "locations"
		indentLevel: 1
		iconSource: "system-file-manager"
		text: i18n("locations")
	}

	SearchFiltersViewItem {
		runnerId: "Dictionary"
		indentLevel: 1
		iconSource: "accessories-dictionary"
		text: i18n("Dictionary")
		onApplyButtonClicked: search.setQueryPrefix('define ')
	}

	SearchFiltersViewItem {
		runnerId: "shell"
		indentLevel: 1
		iconSource: "system-run"
		text: i18n("Shell")
	}

	SearchFiltersViewItem {
		runnerId: "calculator"
		indentLevel: 1
		iconSource: "accessories-calculator"
		text: i18n("Calculator")
	}

	SearchFiltersViewItem {
		runnerId: "org.kde.windowedwidgets"
		indentLevel: 1
		iconSource: ""
		text: i18n("Windowed Widgets")
	}

	SearchFiltersViewItem {
		runnerId: "org.kde.datetime"
		indentLevel: 1
		iconSource: ""
		text: i18n("Date/Time")
	}

	SearchFiltersViewItem {
		runnerId: "unitconverter"
		indentLevel: 1
		iconSource: ""
		text: i18n("Unit Converter")
	}
}
