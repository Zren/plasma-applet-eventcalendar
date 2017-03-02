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
	property alias subText: applyFilterButton.subText

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
		// visible: isDefaultFilter.visible && searchFiltersViewItem.indentLevel > 0
	}


	Item { // Align CheckBoxes buttons to "All"
		// Layout.minimumWidth: (isDefaultFilter.Layout.preferredWidth + surfaceNormal.margins.left) * (searchFiltersViewItem.indentLevel - (isDefaultFilter.visible ? 1 : 0))
		Layout.minimumWidth: (isDefaultFilter.Layout.minimumWidth + surfaceNormal.margins.left) * searchFiltersViewItem.indentLevel
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
	}

	PlasmaComponents.ToolButton {
		id: applyFilterButton
		Layout.fillWidth: true
		property string subText: ""

		style: PlasmaStyles.ToolButtonStyle {
			id: style
			label: RowLayout {
				PlasmaCore.IconItem {
					source: control.iconSource
				}
				ColumnLayout {
					Layout.fillWidth: true
					spacing: 0
					PlasmaComponents.Label {
						Layout.fillWidth: true
						text: control.text
						horizontalAlignment: Text.AlignLeft
						maximumLineCount: 1
						elide: Text.ElideRight
					}
					PlasmaComponents.Label {
						Layout.fillWidth: true
						text: control.subText
						horizontalAlignment: Text.AlignLeft
						visible: control.subText
						color: config.menuItemTextColor2
						maximumLineCount: 1
						elide: Text.ElideRight
					}
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
		Layout.minimumWidth: config.flatButtonIconSize
		Layout.preferredWidth: implicitWidth
		implicitHeight: -1
		text: i18n("Default")
	}

	Item { // Align CheckBoxes buttons to "All"
		Layout.minimumWidth: surfaceNormal.margins.right
		Layout.maximumWidth: Layout.minimumWidth
		Layout.fillHeight: true
		// visible: isDefaultFilter.visible && searchFiltersViewItem.indentLevel > 0
	}
}
