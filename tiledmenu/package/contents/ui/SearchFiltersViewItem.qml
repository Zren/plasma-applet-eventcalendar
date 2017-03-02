import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import QtQuick.Controls.Styles 1.1 as QtQuickControlStyle
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

RowLayout {
	id: searchFiltersViewItem
	Layout.fillWidth: true
	spacing: 0

	property string runnerId: ''
	property int indentLevel: 0

	property alias iconSource: applyFilterButton.iconSource
	property alias text: applyFilterButton.text

	property alias checkBox: isDefaultFilter
	property alias applyButton: applyFilterButton

	signal applyButtonClicked()

	property var surfaceNormal: PlasmaCore.FrameSvgItem {
		anchors.fill: parent
		imagePath: "widgets/button"
		prefix: "normal"
		// prefix: style.flat ? ["toolbutton-hover", "normal"] : "normal"
	}

	Item { // Align CheckBoxes buttons to "All"
		Layout.minimumWidth: surfaceNormal.margins.left
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
		visible: isDefaultFilter.visible && searchFiltersViewItem.indentLevel > 0
	}


	Item { // Align CheckBoxes buttons to "All"
		Layout.minimumWidth: (isDefaultFilter.Layout.preferredWidth + surfaceNormal.margins.left) * (searchFiltersViewItem.indentLevel - (isDefaultFilter.visible ? 1 : 0))
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
	}

	PlasmaComponents.CheckBox {
		id: isDefaultFilter
		checked: search.defaultFilters.indexOf(searchFiltersViewItem.runnerId) != -1
		enabled: false
		onCheckedChanged: {
			if (checked) {

			} else {

			}
		}
		// Layout.fillHeight: true
		Layout.preferredHeight: config.flatButtonIconSize
		Layout.preferredWidth: config.flatButtonIconSize
		implicitHeight: -1
	}

	PlasmaComponents.ToolButton {
		id: applyFilterButton
		Layout.fillWidth: true
		style: PlasmaStyles.ToolButtonStyle {
			id: style
			label: RowLayout {
				PlasmaCore.IconItem {
					source: control.iconSource
				}
				PlasmaComponents.Label {
					text: control.text
					Layout.fillWidth: true
					horizontalAlignment: Text.AlignLeft
				}
			}
		}
		onClicked: {
			if (searchFiltersViewItem.runnerId) {
				search.filters = [searchFiltersViewItem.runnerId]
			}
			searchFiltersViewItem.applyButtonClicked()
			searchResultsView.filterViewOpen = false
		}
	}
}
